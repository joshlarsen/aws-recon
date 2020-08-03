class SageMaker < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_notebook_instances
    #
    @client.list_notebook_instances.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.notebook_instances.each do |instance|
        struct = OpenStruct.new(instance.to_h)
        struct.type = 'notebook_instance'
        struct.arn = instance.notebook_instance_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
