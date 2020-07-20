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
        struct.record_sets = []

        # list_resource_record_sets
        @client.list_resource_record_sets({ hosted_zone_id: zone.id }).each_with_index do |response, page|
          log(response.context.operation_name, zone.name.downcase, page)

          response.resource_record_sets.each do |record_set|
            struct.record_sets.push(record_set.to_h)
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
