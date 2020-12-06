class CodePipeline < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_pipelines
    #
    begin
      @client.list_pipelines.each_with_index do |response, page|
        log(response.context.operation_name, page)

        # get_pipeline
        response.pipelines.each do |pipeline|
          resp = @client.get_pipeline(name: pipeline.name)
          struct = OpenStruct.new(resp.pipeline.to_h)
          struct.type = 'pipeline'
          struct.arn = resp.metadata.pipeline_arn

          resources.push(struct.to_h)
        end
      end
    rescue Aws::CodePipeline::Errors::ServiceError => e
      log_error(e.code)

      unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
        raise e
      end
    end

    resources
  end

  private

  # not an error
  def suppressed_errors
    %w[
      AccessDeniedException
    ]
  end
end
