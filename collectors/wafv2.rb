class WAFV2 < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
  # TODO: resolve scope (e.g. CLOUDFRONT supported?)
  # TODO: confirm paging behavior
  #
  def collect
    resources = []

    #
    # list_web_acls
    #
    # %w[CLOUDFRONT REGIONAL].each do |scope|
    %w[REGIONAL].each do |scope|
      @client.list_web_acls({ scope: scope }).each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.web_acls.each do |acl|
          struct = OpenStruct.new(acl.to_h)
          struct.type = 'web_acl'
          # struct.arn = "arn:aws:#{@service}:#{@region}::web_acl/#{acl.id}"

          params = {
            name: acl.name,
            scope: scope,
            id: acl.id
          }

          # get_web_acl
          @client.get_web_acl(params).each do |response|
            struct.arn = response.web_acl.arn
            struct.details = response.web_acl
          end

          # list_resources_for_web_acl
          @client.list_resources_for_web_acl({ web_acl_arn: 'ResourceArn' }).each do |response|
            struct.resources = response.resource_arns.map(&:to_h)
          end

          resources.push(struct.to_h)
        end
      end
    end

    resources
  end
end
