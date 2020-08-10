class Route53Domains < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_domains
    #
    @client.list_domains.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.domains.each do |domain|
        struct = OpenStruct.new(domain.to_h)
        struct.type = 'domain'
        struct.arn = "arn:aws:#{@service}:#{@region}::domain/#{domain.domain_name}"

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
