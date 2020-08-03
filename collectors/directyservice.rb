class DirectoryService < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: confirm paging behavior
  #
  def collect
    resources = []

    #
    # describe_directories
    #
    @client.describe_directories.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.directory_descriptions.each do |directory|
        struct = OpenStruct.new(directory.to_h)
        struct.type = 'directory'
        struct.arn = "arn:aws:#{@service}:#{@region}::directory/#{directory.directory_id}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
