class Support < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_trusted_advisor_checks
    #
    @client.describe_trusted_advisor_checks({ language: 'en' }).each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.checks.each do |check|
        struct = OpenStruct.new(check.to_h)
        struct.type = 'trusted_advisor_check'
        struct.arn = "arn:aws:support::trusted_advisor_check/#{check.id}"

        # describe_trusted_advisor_check_result
        struct.result = @client.describe_trusted_advisor_check_result({ check_id: check.id }).result.to_h
        log(response.context.operation_name, 'describe_trusted_advisor_check_result', check.id)

        resources.push(struct.to_h)
      end
    end

    resources
  rescue Aws::Support::Errors::ServiceError => e
    log_error(e.code)

    unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
      raise e
    end

    [] # no Support subscription
  end

  private

  # not an error
  def suppressed_errors
    %w[
      AccessDeniedException
      SubscriptionRequiredException
    ]
  end
end
