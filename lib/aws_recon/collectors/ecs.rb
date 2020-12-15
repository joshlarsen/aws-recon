class ECS < Mapper
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

      response.cluster_arns.each do |cluster|
        struct = OpenStruct.new(@client.describe_clusters({ clusters: [cluster] }).clusters.first.to_h)
        struct.type = 'cluster'
        struct.arn = cluster
        struct.tasks = []

        # list_tasks
        @client.list_tasks({ cluster: cluster }).each_with_index do |response, page|
          log(response.context.operation_name, 'list_tasks', page)

          # describe_tasks
          response.task_arns.each do |task_arn|
            @client.describe_tasks({ cluster: cluster, tasks: [task_arn] }).tasks.each do |task|
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
