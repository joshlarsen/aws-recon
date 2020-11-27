class Backup < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_backup_plans
    #
    @client.list_protected_resources.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.results.each do |resource|
        struct = OpenStruct.new(resource.to_h)
        struct.type = 'protected_resource'
        struct.arn = resource.resource_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
