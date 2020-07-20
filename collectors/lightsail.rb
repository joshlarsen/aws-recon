class Lightsail < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_instances
    #
    @client.get_instances.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.instances.each do |instance|
        struct = OpenStruct.new(instance.to_h)
        struct.type = 'instance'

        resources.push(struct.to_h)
      end
    end

    #
    # get_load_balancers
    #
    @client.get_load_balancers.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.load_balancers.each do |load_balancer|
        struct = OpenStruct.new(load_balancer.to_h)
        struct.type = 'load_balancer'

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
