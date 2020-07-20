class ElasticsearchService < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_domain_names
    #
    @client.list_domain_names.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.domain_names.each do |domain|
        log(response.context.operation_name, 'describe_elasticsearch_domain', page)

        # describe_elasticsearch_domains
        struct = OpenStruct.new(@client.describe_elasticsearch_domain({ domain_name: domain.domain_name }).domain_status.to_h)
        struct.type = 'domain'

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
