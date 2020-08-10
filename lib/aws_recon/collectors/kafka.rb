class Kafka < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
  #
  def collect
    resources = []

    #
    # list_clusters
    #
    @client.list_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.cluster_info_list.each do |cluster|
        struct = OpenStruct.new(cluster.to_h)
        struct.type = 'cluster'
        struct.arn = cluster.cluster_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
