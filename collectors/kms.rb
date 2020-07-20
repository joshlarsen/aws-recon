class KMS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_keys
    #
    @client.list_keys.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_key
      response.keys.each do |key|
        log(response.context.operation_name, 'describe_key', page)
        struct = OpenStruct.new(@client
                                .describe_key({ key_id: key.key_id })
                                .key_metadata.to_h)
        struct.type = 'key'
        struct.grants = []

        # get_key_rotation_status
        log(response.context.operation_name, 'get_key_rotation_status')
        struct.rotation_enabled = @client
                                  .get_key_rotation_status({ key_id: key.key_id })
                                  .key_rotation_enabled

        # list_grants
        @client.list_grants({ key_id: key.key_id }).each_with_index do |response, page|
          log(response.context.operation_name, 'list_grants', page)

          response.grants.each do |grant|
            struct.grants.push(grant.to_h)
          end
        end

        # get_key_policy - 'default' is the only valid policy
        log(response.context.operation_name, 'get_key_policy')
        struct.policy = @client
                        .get_key_policy({ key_id: key.key_id, policy_name: 'default' })
                        .policy

        # list_aliases
        log(response.context.operation_name, 'list_aliases')
        struct.aliases = @client
                         .list_aliases({ key_id: key.key_id })
                         .aliases.map(&:to_h)

      rescue Aws::KMS::Errors::ServiceError => e
        log_error(e.code)
        raise e unless suppressed_errors.include?(e.code)
      ensure
        resources.push(struct.to_h)
      end
    end

    resources
  end

  private

  # may or may not be an error - EKS isn't available in all regions
  def suppressed_errors
    %w[
      AccessDeniedException
    ]
  end
end
