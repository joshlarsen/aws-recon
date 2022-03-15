# frozen_string_literal: true

#
# Collect ECR resources
#
class ECR < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_repositories
    #
    @client.describe_repositories.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.repositories.each do |repo|
        struct = OpenStruct.new(repo.to_h)
        struct.type = 'repository'
        struct.arn = repo.repository_arn
        struct.policy = @client
                        .get_repository_policy({ repository_name: repo.repository_name }).policy_text.parse_policy

        struct.images = []
        #
        # describe images
        #
        @client.list_images( {repository_name: repo.repository_name}).image_ids.each_with_index do | image, page |
          log(response.context.operation_name, 'list_images', page)
          image_hash = image.to_h
          # 
          # describe image scan results
          #
          result = @client.describe_image_scan_findings({ repository_name: repo.repository_name, image_id: { image_digest: image.image_digest, image_tag: image.image_tag } })
          image_hash["image_scan_status"] = result.image_scan_status.to_h
          image_hash["image_scan_findings"] = result.image_scan_findings.to_h

          rescue Aws::ECR::Errors::ScanNotFoundException => e
            # No scan result for this image. No action needed
          ensure
            struct.images << image_hash
        end
      rescue Aws::ECR::Errors::ServiceError => e
        log_error(e.code)

        raise e unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
      ensure
        resources.push(struct.to_h)
      end
    end

    resources
  end

  private

  # not an error
  def suppressed_errors
    %w[
      RepositoryPolicyNotFoundException,
      ScanNotFoundException
      ]
  end
end
