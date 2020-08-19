class ElastiCache < Mapper
  def collect
    resources = []

    #
    # describe_cache_clusters
    #
    @client.describe_cache_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.cache_clusters.each do |cluster|
        struct = OpenStruct.new(cluster.to_h)
        struct.type = 'cluster'
        struct.arn = cluster.arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
