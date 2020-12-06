class SecurityHub < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_hub
    #
    begin
      @client.describe_hub.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new(response.to_h)
        struct.type = 'hub'
        struct.arn = response.hub_arn

        resources.push(struct.to_h)
      end
    rescue Aws::SecurityHub::Errors::ServiceError => e
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
      InvalidAccessException
    ]
  end
end
