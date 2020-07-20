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
  end
end
