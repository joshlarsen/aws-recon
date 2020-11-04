class IAM < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_account_authorization_details
    #   list_mfa_devices
    #   list_ssh_public_keys
    #
    @client.get_account_authorization_details.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # users
      response.user_detail_list.each do |user|
        struct = OpenStruct.new(user.to_h)
        struct.type = 'user'
        struct.mfa_devices = @client.list_mfa_devices({ user_name: user.user_name }).mfa_devices.map(&:to_h)
        struct.ssh_keys = @client.list_ssh_public_keys({ user_name: user.user_name }).ssh_public_keys.map(&:to_h)

        resources.push(struct.to_h)
      end

      # groups
      response.group_detail_list.each do |group|
        struct = OpenStruct.new(group.to_h)
        struct.type = 'group'

        resources.push(struct.to_h)
      end

      # roles
      response.role_detail_list.each do |role|
        struct = OpenStruct.new(role.to_h)
        struct.type = 'role'

        resources.push(struct.to_h)
      end

      # polices
      response.policies.each do |policy|
        struct = OpenStruct.new(policy.to_h)
        struct.type = 'policy'

        resources.push(struct.to_h)
      end
    end

    #
    # list_policies
    #
    @client.list_policies.each do |response|
      log(response.context.operation_name)

      # managed policies
      response.policies.each do |policy|
        struct = OpenStruct.new(policy.to_h)
        struct.type = 'managed_policy'

        resources.push(struct.to_h)
      end
    end

    #
    # get_account_password_policy
    #
    @client.get_account_password_policy.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.password_policy.to_h)
      struct.type = 'password_policy'
      struct.arn = "arn:aws:iam::#{@account}:account_password_policy/global"

      resources.push(struct.to_h)
    end

    #
    # get_account_summary
    #
    @client.get_account_summary.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.summary_map)
      struct.type = 'account_summary'
      struct.arn = "arn:aws:iam::#{@account}:account_summary/global"

      resources.push(struct.to_h)
    end

    #
    # list_server_certificates
    #
    @client.list_server_certificates.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.server_certificate_metadata_list.each do |cert|
        struct = OpenStruct.new(cert)
        struct.type = 'server_certificate'
        struct.arn = cert.arn

        resources.push(struct.to_h)
      end
    end

    #
    # list_virtual_mfa_devices
    #
    @client.list_virtual_mfa_devices.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.virtual_mfa_devices.each do |mfa_device|
        struct = OpenStruct.new(mfa_device.to_h)
        struct.type = 'virtual_mfa_device'
        struct.arn = mfa_device.serial_number

        resources.push(struct.to_h)
      end
    end

    #
    # get_credential_report
    #
    begin
      @client.get_credential_report.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new
        struct.type = 'credential_report'
        struct.arn = "arn:aws:iam::#{@account}:credential_report/global"
        struct.content = CSV.parse(response.content, headers: :first_row).map(&:to_h)
        struct.report_format = response.report_format
        struct.generated_time = response.generated_time

        resources.push(struct.to_h)
      end
    rescue Aws::IAM::Errors::ServiceError => e
      log_error(e.code)
      raise e unless suppressed_errors.include?(e.code)
    end

    resources
  end

  private

  # not an error
  def suppressed_errors
    %w[
      ReportNotPresent
    ]
  end
end
