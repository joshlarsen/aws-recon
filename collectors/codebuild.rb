class CodeBuild < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: group projects in chucks to minimize batch_get calls
  #
  def collect
    resources = []

    #
    # list_projects
    #
    @client.list_projects.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # batch_get_projects
      response.projects.each do |project_name|
        @client.batch_get_projects({ names: [project_name] }).projects.each do |project|
          struct = OpenStruct.new(project.to_h)
          struct.type = 'project'

          resources.push(struct.to_h)
        end
      end
    end

    resources
  end
end
