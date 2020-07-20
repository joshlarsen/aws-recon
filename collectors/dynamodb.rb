class DynamoDB < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

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

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
