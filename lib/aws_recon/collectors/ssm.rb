class SSM < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_instance_information
    #
    @client.describe_instance_information.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.instance_information_list.each do |instance|
        struct = OpenStruct.new(instance.to_h)
        struct.type = 'instance'
        struct.arn = instance.instance_id

        resources.push(struct.to_h)
      end
    end

    #
    # describe_parameters
    #
    @client.describe_parameters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.parameters.each do |parameter|
        struct = OpenStruct.new(parameter.to_h)
        struct.string_type = parameter.type
        struct.type = 'parameter'
        struct.arn = "arn:aws:#{@service}:#{@region}::parameter:#{parameter.name}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
