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
        log(response.context.operation_name, bucket.name)

        struct = OpenStruct.new(bucket)
        struct.type = 'bucket'
        struct.arn = "arn:aws:s3:::#{bucket.name}"

        # check bucket region constraint, update client if necessary
        location = @client.get_bucket_location({ bucket: bucket.name }).location_constraint

        unless location.empty?
          @client = Aws::S3::Client.new({ region: location })
        end

        operations = [
          { func: 'get_bucket_acl', key: 'acl', field: nil },
          { func: 'get_bucket_encryption', key: 'encryption', field: 'server_side_encryption_configuration' },
          { func: 'get_bucket_policy', key: 'policy', field: 'policy' },
          { func: 'get_bucket_policy_status', key: 'public', field: 'policy_status' },
          { func: 'get_bucket_tagging', key: 'tagging', field: nil },
          { func: 'get_bucket_logging', key: 'logging', field: 'logging_enabled' },
          { func: 'get_bucket_versioning', key: 'versioning', field: nil },
          { func: 'get_bucket_website', key: 'website', field: nil }
        ]

        operations.each do |operation|
          op = OpenStruct.new(operation)

          resp = @client.send(op.func, { bucket: bucket.name })

          struct[op.key] = if op.key == 'policy'
                             resp.policy.string
                           else
                             op.field ? resp.send(op.field).to_h : resp.to_h
                           end

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
