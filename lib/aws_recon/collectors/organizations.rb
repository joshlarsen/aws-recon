class Organizations < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_organization
    #
    @client.describe_organization.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.organization.to_h)
      struct.type = 'organization'

      resources.push(struct.to_h)
    end

    #
    # list_handshakes_for_account
    #
    @client.list_handshakes_for_account.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.handshakes.each do |handshake|
        struct = OpenStruct.new(handshake.to_h)
        struct.type = 'handshake'

        resources.push(struct.to_h)
      end
    end

    #
    # list_policies
    #
    @client.list_policies({ filter: 'SERVICE_CONTROL_POLICY' }).each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.policies.each do |policy|
        struct = OpenStruct.new(policy.to_h)
        struct.type = 'service_control_policy'
        struct.content = JSON.parse(CGI.unescape(@client.describe_policy({ policy_id: policy.id }).policy.content))

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
