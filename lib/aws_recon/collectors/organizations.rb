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

    resources
  end
end
