class Lambda < Mapper
  def collect
    resources = []

    #
    # list_functions
    #
    @client.list_functions.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.functions.each do |function|
        struct = OpenStruct.new(function)
        struct.type = 'function'
        struct.arn = function.function_arn
        struct.policy = @client.get_policy({ function_name: function.function_name }).policy.parse_policy

      rescue Aws::Lambda::Errors::ResourceNotFoundException => e
        log_error(e.code)
      ensure
        resources.push(struct.to_h)
      end
    end

    #
    # list_layers
    #
    @client.list_layers.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.layers.each do |layer|
        struct = OpenStruct.new(layer)
        struct.type = 'layer'
        struct.arn = layer.layer_arn

        # list_layer_versions
        struct.versions = @client.list_layer_versions({ layer_name: layer.layer_name }).layer_versions.map(&:to_h)
        log(response.context.operation_name, 'list_layer_versions')

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
