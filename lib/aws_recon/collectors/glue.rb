# frozen_string_literal: true

#
# Collect Glue resources
#
class Glue < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []
    # 
    # get_data_catalog_encryption_settings
    #
    @client.get_data_catalog_encryption_settings.each_with_index do | response, page|
      log(response.context.operation_name, page)

      struct = OpenStruct.new(response.to_h)
      struct.type = 'catalog_encryption_settings'
      struct.arn = "arn:aws:glue:#{@region}:#{@account}:data-catalog-encryption-settings" # no true ARN
      resources.push(struct.to_h)
    end

    #
    # get_security_configurations
    #
    @client.get_security_configurations.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.security_configurations.each do | security_configuration |
          struct = OpenStruct.new(security_configuration.to_h)
          struct.type = 'security_configuration'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:security-configuration/#{security_configuration.name}" # no true ARN
          resources.push(struct.to_h)
      end
    end

    #
    # get_databases
    #
    @client.get_databases.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.database_list.each do | database |
          struct = OpenStruct.new(database.to_h)
          struct.type = 'database'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:database/#{database.name}" 

          #
          # get_tables
          # 
          tables = @client.get_tables({database_name: database.name})
          struct.tables = tables.to_h

          resources.push(struct.to_h)
      end
    end  

    # 
    # get_jobs
    #
    @client.get_jobs.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.jobs.each do | job |
          struct = OpenStruct.new(job.to_h)
          struct.type = 'job'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:job/#{job.name}" 
          resources.push(struct.to_h)
      end
    end

    # 
    # get_dev_endpoints
    #
    @client.get_dev_endpoints.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.dev_endpoints.each do | dev_endpoint |
          struct = OpenStruct.new(dev_endpoint.to_h)
          struct.type = 'dev_endpoint'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:devEndpoint/#{dev_endpoint.endpoint_name}" 
          resources.push(struct.to_h)
      end
    end

    # 
    # get_crawlers
    #
    @client.get_crawlers.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.crawlers.each do | crawler |
          struct = OpenStruct.new(crawler.to_h)
          struct.type = 'crawler'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:crawler/#{crawler.name}"
          resources.push(struct.to_h)
      end
    end

    # 
    # get_connections
    #
    @client.get_connections.each_with_index do | response, page |
      log(response.context.operation_name, page)

      response.connection_list.each do | connection |
          struct = OpenStruct.new(connection.to_h)
          struct.type = 'connection'
          struct.arn = "arn:aws:glue:#{@region}:#{@account}:connection/#{connection.name}"
          resources.push(struct.to_h)
      end
    end
    resources
  end

end
