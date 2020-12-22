# frozen_string_literal: true

#
# Collect SageMaker Resources
#
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
        struct = OpenStruct.new(@client.describe_notebook_instance({
                                                                     notebook_instance_name: instance.notebook_instance_name
                                                                   }).to_h)
        struct.type = 'notebook_instance'
        struct.arn = instance.notebook_instance_arn

        resources.push(struct.to_h)
      end
    end

    #
    # list_endpoints
    #
    @client.list_endpoints.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.endpoints.each do |instance|
        struct = OpenStruct.new(@client.describe_endpoint({
                                                            endpoint_name: instance.endpoint_name
                                                          }).to_h)
        struct.type = 'endpoint'
        struct.arn = instance.endpoint_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
