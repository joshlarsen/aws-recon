class SecretsManager < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_auto_scaling_groups
    #
    @client.list_secrets.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.secret_list.each_with_index do |secret, i|
        log(response.context.operation_name, i)

        struct = OpenStruct.new(secret.to_h)
        struct.type = 'secret'

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
