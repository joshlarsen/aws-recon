class DirectConnect < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_connections
    #
    @client.describe_connections.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.connections.each do |connection|
        struct = OpenStruct.new(connection.to_h)
        struct.type = 'connection'
        struct.arn = "arn:aws:service:#{@service}::connection/#{connection.connection_id}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
