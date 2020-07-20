class SSM < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
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

    resources
  end
end
