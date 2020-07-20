class Kinesis < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_streams
    #
    @client.list_streams.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_stream
      response.stream_names.each do |stream|
        struct = OpenStruct.new(@client.describe_stream({ stream_name: stream }).stream_description.to_h)
        struct.type = 'stream'
        struct.arn = struct.stream_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
