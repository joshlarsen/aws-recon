# frozen_string_literal: true

#
# Collect Org resources
#
class Organizations < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_organization
    #
    begin
      @client.describe_organization.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new(response.organization.to_h)
        struct.type = 'organization'

        resources.push(struct.to_h)
      end
    rescue Aws::Organizations::Errors::ServiceError => e
      log_error(e.code)

      raise e unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
    end

    #
    # list_handshakes_for_account
    #
    @client.list_handshakes_for_account.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.handshakes.each do |handshake|
        struct = OpenStruct.new(handshake.to_h)
        struct.type = 'handshake'

        resources.push(struct.to_h)
      end
    end

    #
    # list_policies
    #
    begin
      @client.list_policies({ filter: 'SERVICE_CONTROL_POLICY' }).each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.policies.each do |policy|
          struct = OpenStruct.new(policy.to_h)
          struct.type = 'service_control_policy'
          struct.content = @client.describe_policy({ policy_id: policy.id }).policy.content.parse_policy

          resources.push(struct.to_h)
        end
      end
    rescue Aws::Organizations::Errors::ServiceError => e
      log_error(e.code)

      raise e unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
    end

    resources
  end

  private

  # not an error
  def suppressed_errors
    %w[
      AccessDeniedException
      AWSOrganizationsNotInUseException
    ]
  end
end
