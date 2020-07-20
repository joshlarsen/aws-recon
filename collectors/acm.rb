class ACM < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_certificates
    #
    @client.list_certificates.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.certificate_summary_list.each do |cert|
        log(response.context.operation_name, cert.domain_name, page)

        struct = OpenStruct.new(cert.to_h)
        struct.type = 'certificate'
        struct.arn = cert.certificate_arn

        # describe_certificate
        struct.details = @client
                         .describe_certificate({ certificate_arn: cert.certificate_arn })
                         .certificate.to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
