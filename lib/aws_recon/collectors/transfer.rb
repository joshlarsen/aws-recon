class Transfer < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_servers
    #
    @client.list_servers.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.servers.each do |server|
        struct = OpenStruct.new(server.to_h)
        struct.type = 'server'

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
