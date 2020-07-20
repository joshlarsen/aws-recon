class S3 < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_buckets
    #
    @client.list_buckets.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.buckets.each do |bucket|
        struct = OpenStruct.new(bucket)
        struct.type = 'bucket'
        struct.arn = "arn:aws:s3:::#{bucket.name}"

        # check bucket region constraint, update client if necessary
        location = @client
                   .get_bucket_location({ bucket: bucket.name })
                   .location_constraint

        unless location.empty?
          @client = Aws::S3::Client.new({ region: location })
        end

        # other bucket details
        operations = %w[
          acl
          encryption
          policy
          policy_status
          tagging
          logging
          versioning
          website
        ]

        operations.each do |operation|
          log(response.context.operation_name, operation)
          struct[operation] = @client.send("get_bucket_#{operation}", { bucket: bucket.name }).to_h

        rescue Aws::S3::Errors::ServiceError => e
          raise e unless suppressed_errors.include?(e.code)
        end

        # new client with "no region" if it was updated for location_constraint
        @client = Aws::S3::Client.new unless location.empty?

        resources.push(struct.to_h)
      end
    end

    resources
  end

  private

  # these aren't really errors
  def suppressed_errors
    %w[
      ServerSideEncryptionConfigurationNotFoundError
      NoSuchBucketPolicy
      NoSuchTagSet
      NoSuchWebsiteConfiguration
    ]
  end
end
