class DatabaseMigrationService < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_replication_instances
    #
    @client.describe_replication_instances.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.replication_instances.each do |instance|
        struct = OpenStruct.new(instance.to_h)
        struct.type = 'replication_instance'
        struct.arn = "arn:aws:#{@service}:#{@region}::replication_instance/#{instance.replication_instance_identifier}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
