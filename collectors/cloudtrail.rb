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
        if @region != trail.home_region
          @client = Aws::CloudTrail::Client.new({ region: trail.home_region })
        end

        struct = OpenStruct.new(trail.to_h)
        struct.tags = @client.list_tags({ resource_id_list: [trail.trail_arn] }).resource_tag_list.first.tags_list
        struct.type = 'cloud_trail'
        struct.arn = trail.trail_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
