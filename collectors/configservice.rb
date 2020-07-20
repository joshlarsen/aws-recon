class ConfigService < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_config_rules
    #
    @client.describe_config_rules.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.config_rules.each do |rule|
        struct = OpenStruct.new(rule.to_h)
        struct.type = 'rule'
        struct.arn = rule.config_rule_arn

        # describe_config_rule_evaluation_status
        @client.describe_config_rule_evaluation_status({ config_rule_names: [rule.config_rule_name] }).each do |response|
          log(response.context.operation_name, rule.config_rule_name, page)

          response.config_rules_evaluation_status.each do |status|
            struct.evaluation_status = status.to_h
          end
        end

        resources.push(struct.to_h)
      end
    end

    #
    # describe_configuration_recorders
    #
    @client.describe_configuration_recorders.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.configuration_recorders.each do |recorder|
        struct = OpenStruct.new(recorder.to_h)
        struct.type = 'configuration_recorder'
        struct.arn = "arn:aws:config:#{@region}:configuration_recorder/#{recorder.name}"

        # describe_configuration_recorder_status (only accepts one recorder)
        @client.describe_configuration_recorder_status({ configuration_recorder_names: [recorder.name] }).each do |response|
          log(response.context.operation_name, recorder.name, page)

          response.configuration_recorders_status.each do |status|
            struct.status = status.to_h
          end
        end

        resources.push(struct.to_h)
      end
    end

    #
    # describe_delivery_channels
    #
    @client.describe_delivery_channels.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.delivery_channels.each do |channel|
        struct = OpenStruct.new(channel.to_h)
        struct.type = 'delivery_channel'
        struct.arn = "arn:aws:config:#{@region}:delivery_channel/#{channel.name}"

        # describe_delivery_channel_status (only accepts one channel)
        @client.describe_delivery_channel_status({ delivery_channel_names: [channel.name] }).each do |response|
          response.delivery_channels_status.each do |status|
            struct.status = status.to_h
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
