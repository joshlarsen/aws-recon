class CloudFormation < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_stacks
    #
    @client.describe_stacks.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.stacks.each do |stack|
        struct = OpenStruct.new(stack.to_h)
        struct.type = 'stack'
        struct.arn = stack.stack_id

        # get_template
        struct.tempate = @client.get_template({ stack_name: stack.stack_name }).to_h
        log(response.context.operation_name, 'get_template', stack.stack_name)

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
