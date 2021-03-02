# frozen_string_literal: true

#
# Collect EMR resources
#
class EMR < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_block_public_access_configuration
    #
    begin
      @client.get_block_public_access_configuration.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new(response.block_public_access_configuration.to_h)
        struct.type = 'configuration'
        struct.arn = "arn:aws:emr:#{@region}:#{@account}/block_public_access_configuration"

        resources.push(struct.to_h)
      end
    rescue Aws::EMR::Errors::ServiceError => e
      log_error(e.code)

      raise e unless suppressed_errors.include?(e.code) && !@options.quit_on_exception
    end

    #
    # list_clusters
    #
    @client.list_clusters.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.clusters.each do |cluster|
        log(response.context.operation_name, cluster.id)

        struct = OpenStruct.new(@client.describe_cluster({ cluster_id: cluster.id }).cluster.to_h)
        struct.type = 'cluster'
        struct.arn = cluster.cluster_arn

        resources.push(struct.to_h)
      end
    end

    resources
  end

  private

  def suppressed_errors
    %w[
      InvalidRequestException
    ]
  end
end
