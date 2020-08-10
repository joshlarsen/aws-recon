class Athena < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_work_groups
    #
    @client.list_work_groups.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.work_groups.each do |workgroup|
        struct = OpenStruct.new(workgroup.to_h)
        struct.type = 'workgroup'
        struct.arn = "arn:aws:athena:#{@region}::workgroup/#{workgroup.name}"

        # get_work_group
        struct.details = @client.get_work_group({ work_group: workgroup.name }).to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
