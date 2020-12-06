class Shield < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_subscription
    #
    @client.describe_subscription.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new(response.subscription.to_h)
      struct.type = 'subscription'
      struct.arn = "arn:aws:shield:#{@region}:#{@account}:subscription"

      resources.push(struct.to_h)
    end

    #
    # describe_emergency_contact_settings
    #
    @client.describe_emergency_contact_settings.each do |response|
      log(response.context.operation_name)

      struct = OpenStruct.new
      struct.type = 'contact_list'
      struct.arn = "arn:aws:shield:#{@region}:#{@account}:contact_list"
      struct.contacts = response.emergency_contact_list.map(&:to_h)

      resources.push(struct.to_h)
    end

    #
    # list_protections
    #
    @client.list_protections.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # describe_protection
      response.protections.each do |protection|
        struct = OpenStruct.new(@client.describe_protection({ protection_id: protection.id }).protection.to_h)
        struct.type = 'protection'
        struct.arn = protection.resource_arn

        resources.push(struct.to_h)
      end
    end

    resources
  rescue Aws::Shield::Errors::ServiceError => e
    log_error(e.code)

    unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
      raise e
    end

    [] # no access or service isn't enabled
  end

  private

  # not an error
  def suppressed_errors
    %w[
      ResourceNotFoundException
    ]
  end
end
