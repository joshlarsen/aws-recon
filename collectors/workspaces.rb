class WorkSpaces < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []
    #
    # describe_workspaces
    #
    @client.describe_workspaces.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.workspaces.each do |workspace|
        struct = OpenStruct.new(workspace.to_h)
        struct.type = 'workspace'
        struct.arn = "arn:aws:workspaces:#{@region}::workspace/#{workspace.workspace_id}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
