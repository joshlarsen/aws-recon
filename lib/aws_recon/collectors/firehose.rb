class Firehose < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
  # TODO: confirm paging behavior
  #
  def collect
    resources = []

    #
    # list_delivery_streams
    #
    @client.list_delivery_streams.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_delivery_stream
      response.delivery_stream_names.each do |stream|
        struct = OpenStruct.new(@client.describe_delivery_stream({ delivery_stream_name: stream }).delivery_stream_description.to_h)
        struct.type = 'stream'
        struct.arn = struct.delivery_stream_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
