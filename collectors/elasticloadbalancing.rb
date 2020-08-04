class ElasticLoadBalancing < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_load_balancers
    #
    @client.describe_load_balancers.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.load_balancer_descriptions.each do |elb|
        struct = OpenStruct.new(elb.to_h)
        struct.type = 'load_balancer'
        struct.arn = elb.dns_name

        # describe_load_balancer_policies
        struct.policies = @client
                          .describe_load_balancer_policies({ load_balancer_name: elb.load_balancer_name })
                          .policy_descriptions.map(&:to_h)

        # describe_load_balancer_attributes
        struct.attributes = @client
                            .describe_load_balancer_attributes({ load_balancer_name: elb.load_balancer_name })
                            .load_balancer_attributes.to_h

        # describe_tags
        struct.tags = @client
                      .describe_tags({ load_balancer_names: [elb.load_balancer_name] })
                      .tag_descriptions.map(&:tags)
                      .flatten.map(&:to_h)

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
