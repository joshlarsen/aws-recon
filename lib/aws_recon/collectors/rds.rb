class RDS < Mapper
  #
  # Returns an array of resources.
  #
  # describe_db_engine_versions is skipped with @options.skip_slow
  #
  def collect
    resources = []

    #
    # describe_db_clusters
    #
    @client.describe_db_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.db_clusters.each do |cluster|
        log(response.context.operation_name, cluster.db_cluster_identifier)

        struct = OpenStruct.new(cluster.to_h)
        struct.type = 'db_cluster'
        struct.arn = cluster.db_cluster_arn

        resources.push(struct.to_h)
      end
    end

    #
    # describe_db_instances
    #
    @client.describe_db_instances.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.db_instances.each do |instance|
        log(response.context.operation_name, instance.db_instance_identifier)

        struct = OpenStruct.new(instance.to_h)
        struct.type = 'db_instance'
        struct.arn = instance.db_instance_arn
        struct.parent_id = instance.db_cluster_identifier

        # TODO: describe_db_snapshots here (with public flag)

        resources.push(struct.to_h)
      end
    end

    #
    # describe_db_snapshots
    #
    @client.describe_db_snapshots.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.db_snapshots.each do |snapshot|
        log(response.context.operation_name, snapshot.db_snapshot_identifier)

        struct = OpenStruct.new(snapshot.to_h)
        struct.type = 'db_snapshot'
        struct.arn = snapshot.db_snapshot_arn
        struct.parent_id = snapshot.db_instance_identifier

        resources.push(struct.to_h)
      end
    end

    #
    # describe_db_engine_versions
    #
    unless @options.skip_slow
      @client.describe_db_engine_versions.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.db_engine_versions.each do |version|
          struct = OpenStruct.new(version.to_h)
          struct.type = 'db_engine_version'

          resources.push(struct.to_h)
        end
      end
    end

    resources
  end
end
