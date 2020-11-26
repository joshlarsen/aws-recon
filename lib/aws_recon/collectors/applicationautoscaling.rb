class ApplicationAutoScaling < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # DynamoDB auto-scaling policies
    #
    @client.describe_scaling_policies({ service_namespace: 'dynamodb' }).each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.scaling_policies.each do |policy|
        struct = OpenStruct.new(policy.to_h)
        struct.type = 'auto_scaling_policy'
        struct.arn = policy.policy_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
