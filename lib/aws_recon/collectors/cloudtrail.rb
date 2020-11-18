class CloudTrail < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []
    #
    # describe_trails
    #
    @client.describe_trails.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.trail_list.each do |trail|
        # list_tags needs to call into home_region
        client = if @region != trail.home_region
                   Aws::CloudTrail::Client.new({ region: trail.home_region })
                 else
                   @client
                 end

        struct = OpenStruct.new(trail.to_h)
        struct.tags = client.list_tags({ resource_id_list: [trail.trail_arn] }).resource_tag_list.first.tags_list
        struct.type = 'cloud_trail'
        struct.event_selectors = client.get_event_selectors({ trail_name: trail.name }).to_h
        struct.status = client.get_trail_status({ name: trail.name }).to_h
        struct.arn = trail.trail_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
