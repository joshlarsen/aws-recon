class SES < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_identities
    #
    @client.list_identities.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.identities.each do |identity|
        struct = OpenStruct.new
        struct.type = 'identity'
        struct.arn = "aws:ses:#{@region}::identity/#{identity}"

        # get_identity_dkim_attributes
        struct.dkim_attributes = @client.get_identity_dkim_attributes({ identities: [identity] }).dkim_attributes[identity].to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
