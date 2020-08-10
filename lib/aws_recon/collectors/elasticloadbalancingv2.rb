class ElasticLoadBalancingV2 < Mapper
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

      response.load_balancers.each do |elb|
        struct = OpenStruct.new(elb.to_h)
        struct.type = 'load_balancer'
        struct.arn = elb.load_balancer_arn
        struct.listeners = []
        struct.target_groups = []

        # describe_load_balancer_attributes
        struct.attributes = @client
                            .describe_load_balancer_attributes({ load_balancer_arn: elb.load_balancer_arn })
                            .attributes.map(&:to_h)

        # describe_tags
        struct.tags = @client
                      .describe_tags({ resource_arns: [elb.load_balancer_arn] })
                      .tag_descriptions.map(&:tags)
                      .flatten.map(&:to_h)

        # describe_listeners
        @client.describe_listeners({ load_balancer_arn: elb.load_balancer_arn }).each_with_index do |response, _page|
          log(response.context.operation_name, page)

          response.listeners.each do |listener|
            struct.listeners.push(listener.to_h)
          end
        end

        # describe_target_groups
        @client.describe_target_groups({ load_balancer_arn: elb.load_balancer_arn }).each_with_index do |response, page|
          log(response.context.operation_name, page)

          response.target_groups.each do |target_group|
            tg = OpenStruct.new(target_group.to_h)

            # describe_target_health
            tg.health_descriptions = @client
                                     .describe_target_health({ target_group_arn: target_group.target_group_arn })
                                     .target_health_descriptions.map(&:to_h)

            struct.target_groups.push(tg.to_h)
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
