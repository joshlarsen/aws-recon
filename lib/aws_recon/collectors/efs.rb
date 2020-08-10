class EFS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_file_systems
    #
    @client.describe_file_systems.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.file_systems.each do |filesystem|
        struct = OpenStruct.new(filesystem.to_h)
        struct.type = 'filesystem'
        struct.arn = filesystem.file_system_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
