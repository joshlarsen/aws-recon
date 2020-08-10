class ApiGatewayV2 < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_apis
    #
    @client.get_apis.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.items.each do |api|
        struct = OpenStruct.new(api.to_h)
        struct.type = 'api'
        struct.arn = api.api_id

        # get_authorizers
        struct.authorizers = @client.get_authorizers({ api_id: api.api_id }).items.map(&:to_h)

        # get_stages
        struct.stages = @client.get_stages({ api_id: api.api_id }).items.map(&:to_h)

        # get_models
        struct.models = @client.get_models({ api_id: api.api_id }).items.map(&:to_h)

        # get_deployments
        struct.deployments = @client.get_deployments({ api_id: api.api_id }).items.map(&:to_h)

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
