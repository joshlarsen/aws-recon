class EKS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_clusters
    #
    @client.list_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_cluster
      response.clusters.each do |cluster|
        struct = OpenStruct.new(@client.describe_cluster({ name: cluster }).cluster.to_h)
        struct.type = 'cluster'
        struct.nodegroups = []

        # list_nodegroups
        @client.list_nodegroups({ cluster_name: cluster }).each_with_index do |response, page|
          log(response.context.operation_name, 'list_nodegroups', page)

          # describe_nodegroup
          response.nodegroups.each do |nodegroup|
            struct.nodegroups.push(@client.describe_nodegroup({ cluster_name: cluster, nodegroup_name: nodegroup }).nodegroup.to_h)
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
