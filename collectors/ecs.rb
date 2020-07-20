class ECS < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
  #
  def collect
    resources = []

    #
    # describe_clusters
    #
    @client.describe_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.clusters.each do |cluster|
        struct = OpenStruct.new(cluster.to_h)
        struct.type = 'cluster'
        struct.arn = cluster.cluster_arn
        struct.tasks = []

        # list_tasks
        @client.list_tasks({ cluster: cluster.cluster_arn }).each_with_index do |response, page|
          log(response.context.operation_name, 'list_tasks', page)

          # describe_tasks
          response.task_arns.each do |task_arn|
            @client.describe_tasks({ cluster: cluster.cluster_arn, tasks: [task_arn] }).tasks.each do |task|
              struct.tasks.push(task)
            end
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
