# frozen_string_literal: true

#
# Collect ECRPublic resources
#
class ECRPublic < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_repositories
    #

    puts(@client.describe_repositories)
    @client.describe_repositories.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.repositories.each do |repo|
        struct = OpenStruct.new(repo.to_h)
        struct.type = "repository"
        struct.arn = repo.repository_arn
        struct.policy = @client
          .get_repository_policy({ repository_name: repo.repository_name }).policy_text.parse_policy

        struct.images = []
        #
        # describe images
        #
        @client.describe_images({ repository_name: repo.repository_name }).image_details.each_with_index do |image, page|
          log(response.context.operation_name, "describe_images", page)
          image_hash = image.to_h
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
