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
        struct.logging_config = @client
                                .list_query_logging_configs({ hosted_zone_id: zone.id })
                                .query_logging_configs.first.to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
