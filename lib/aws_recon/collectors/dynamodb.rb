class DynamoDB < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_limits
    #
    @client.describe_limits.each_with_index do |response, page|
      log(response.context.operation_name, page)

      struct = OpenStruct.new(response)
      struct.type = 'limits'
      struct.arn = "arn:aws:dynamodb:#{@region}:#{@account}:limits"

      resources.push(struct.to_h)
    end

    #
    # list_tables
    #
    @client.list_tables.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_table
      response.table_names.each do |table_name|
        struct = OpenStruct.new(@client.describe_table({ table_name: table_name }).table.to_h)
        struct.type = 'table'
        struct.arn = struct.table_arn
        struct.continuous_backups_description = @client.describe_continuous_backups({ table_name: table_name }).continuous_backups_description.to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
