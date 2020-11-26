class SecurityHub < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_hub
    #
    @client.describe_hub.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.to_h)
      struct.type = 'hub'
      struct.arn = response.hub_arn

      resources.push(struct.to_h)
    end

    resources
  end
end
