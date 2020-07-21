class Route53 < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_hosted_zones
    #
    @client.list_hosted_zones.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.hosted_zones.each do |zone|
        struct = OpenStruct.new(zone.to_h)
        struct.type = 'zone'
        struct.arn = zone.id

        resources.push(struct.to_h)
      end
    end

    #
    # list_query_logging_configs
    #
    @client.list_query_logging_configs.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.query_logging_configs.each do |config|
        struct = OpenStruct.new(config.to_h)
        struct.type = 'logging_config'
        struct.arn = "arn:aws:#{@service}:#{@region}::logging_config/#{config.id}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
