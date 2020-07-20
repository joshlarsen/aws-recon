class CloudWatchLogs < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_log_groups
    #
    @client.describe_log_groups.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.log_groups.each do |log_group|
        struct = OpenStruct.new(log_group.to_h)
        struct.type = 'log_group'
        struct.metric_filters = []

        # describe_metric_filters
        if log_group.metric_filter_count > 0
          @client.describe_metric_filters.each_with_index do |response, page|
            log(response.context.operation_name, log_group.log_group_name, page)

            response.metric_filters.each do |filter|
              struct.metric_filters.push(filter.to_h)
            end
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
