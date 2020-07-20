class AutoScaling < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_auto_scaling_groups
    #
    @client.describe_auto_scaling_groups.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.auto_scaling_groups.each do |asg|
        struct = OpenStruct.new(asg.to_h)
        struct.type = 'auto_scaling_group'
        struct.arn = asg.auto_scaling_group_arn
        struct.policies = []

        # describe_policies
        @client.describe_policies({ auto_scaling_group_name: asg.auto_scaling_group_name }).each_with_index do |response, page|
          log(response.context.operation_name, page)

          response.scaling_policies.each do |policy|
            struct.policies.push(policy.to_h)
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
