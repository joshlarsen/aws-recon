class CloudFront < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_distributions
    #
    @client.list_distributions.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # get_distribution
      response.distribution_list.items.each do |dist|
        struct = OpenStruct.new(dist.to_h)
        struct.type = 'distribution'
        struct.details = @client
                         .get_distribution({ id: dist.id })
                         .distribution.to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
