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
        struct.type = "user"
        struct.mfa_devices = @client.list_mfa_devices({ user_name: user.user_name }).mfa_devices
        struct.ssh_keys = @client.list_ssh_public_keys({ user_name: user.user_name }).ssh_public_keys

        resources.push(struct.to_h)
      end

      # groups
      response.group_detail_list.each do |group|
        struct = OpenStruct.new(group.to_h)
        struct.type = "group"

        resources.push(struct.to_h)
      end

      # roles
      response.role_detail_list.each do |role|
        struct = OpenStruct.new(role.to_h)
        struct.type = "role"

        resources.push(struct.to_h)
      end

      # polices
      response.policies.each do |policy|
        struct = OpenStruct.new(policy.to_h)
        struct.type = "policy"

        resources.push(struct.to_h)
      end
    end

    #
    # get_account_password_policy
    #    
    @client.get_account_password_policy.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.password_policy.to_h)
      struct.type = "password_policy"

      resources.push(struct.to_h)
    end

    #
    # get_account_summary
    #
    @client.get_account_summary.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.summary_map)
      struct.type = "account_summary"

      resources.push(struct.to_h)
    end

    #
    # list_server_certificates
    #
    @client.list_server_certificates.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.server_certificate_metadata_list.each do |cert|
        struct = OpenStruct.new(cert)
        struct.type = "server_certificate"
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
        struct = OpenStruct.new(mfa_device)
        struct.type = "virtual_mfa_device"
        struct.arn = mfa_device.serial_number

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
