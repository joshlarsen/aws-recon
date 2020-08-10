class CloudWatch < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_alarms
    #
    @client.describe_alarms.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.composite_alarms.each do |alarm|
        struct = OpenStruct.new(alarm.to_h)
        struct.type = 'composite_alarm'
        struct.arn = alarm.alarm_arn

        resources.push(struct.to_h)
      end

      response.metric_alarms.each do |alarm|
        struct = OpenStruct.new(alarm.to_h)
        struct.type = 'metric_alarm'
        struct.arn = alarm.alarm_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
