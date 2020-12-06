class ServiceQuotas < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_service_quotas
    #
    # TODO: expand to more services as needed
    #
    # service_codes = %w[autoscaling ec2 ecr eks elasticloadbalancing fargate iam vpc]
    service_codes = %w[ec2 eks iam]

    service_codes.each do |service|
      @client.list_service_quotas({ service_code: service }).each_with_index do |response, page|
        log(response.context.operation_name, service, page)

        response.quotas.each do |quota|
          struct = OpenStruct.new(quota.to_h)
          struct.type = 'quota'
          struct.arn = quota.quota_arn

          resources.push(struct.to_h)
        end
      end
    rescue Aws::ServiceQuotas::Errors::ServiceError => e
      log_error(e.code, service)

      unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
        raise e
      end
    end

    resources
  end

  private

  # not an error
  def suppressed_errors
    %w[
      NoSuchResourceException
    ]
  end
end
