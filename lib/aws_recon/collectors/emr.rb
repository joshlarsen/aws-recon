class EMR < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_block_public_access_configuration
    #
    @client.get_block_public_access_configuration.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.block_public_access_configuration.to_h)
      struct.type = 'configuration'

      resources.push(struct.to_h)
    end

    #
    # list_clusters
    #
    @client.list_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.clusters.each do |cluster|
        log(response.context.operation_name, cluster.id)

        struct = OpenStruct.new(@client.describe_cluster({ cluster_id: cluster.id }).cluster.to_h)
        struct.type = 'cluster'
        struct.arn = cluster.cluster_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
