class EC2 < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []
    image_params = {
      filters: [{ name: 'state', values: ['available'] }],
      owners: ['self']
    }
    snapshot_params = {
      owner_ids: ['self']
    }

    # global calls
    if @region == 'global'

      #
      # get_account_attributes
      #
      @client.describe_account_attributes.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new
        struct.attributes = response.account_attributes.map(&:to_h)
        struct.type = 'account'

        resources.push(struct.to_h)
      end
    end

    # regional calls
    if @region != 'global'
      #
      # get_ebs_encryption_by_default
      #
      @client.get_ebs_encryption_by_default.each do |response|
        log(response.context.operation_name)

        struct = OpenStruct.new(response.to_h)
        struct.type = 'ebs_encryption_settings'

        resources.push(struct.to_h)
      end

      #
      # describe_instances
      #
      @client.describe_instances.each_with_index do |response, page|
        log(response.context.operation_name, page)

        # reservations
        response.reservations.each_with_index do |reservation, page|
          log(response.context.operation_name, 'reservations', page)

          # instances
          reservation.instances.each do |instance|
            struct = OpenStruct.new(instance.to_h)
            struct.type = 'instance'
            struct.arn = instance.instance_id # no true ARN
            struct.reservation_id = reservation.reservation_id

            # collect instance user_data
            if @options.collect_user_data
              user_data_raw = @client.describe_instance_attribute({
                                                                    attribute: 'userData',
                                                                    instance_id: instance.instance_id
                                                                  }).user_data.to_h[:value]

              # don't save non-string user_data
              if user_data_raw
                user_data = Base64.decode64(user_data_raw)

                if user_data.force_encoding('UTF-8').ascii_only?
                  struct.user_data = user_data
                end
              end
            end

            resources.push(struct.to_h)
          end
        end
      end

      #
      # describe_vpcs
      #
      @client.describe_vpcs.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.vpcs.each do |vpc|
          struct = OpenStruct.new(vpc.to_h)
          struct.type = 'vpc'
          struct.arn = vpc.vpc_id # no true ARN
          struct.flow_logs = @client
                             .describe_flow_logs({ filter: [{ name: 'resource-id', values: [vpc.vpc_id] }] })
                             .flow_logs.first.to_h

          resources.push(struct.to_h)
        end
      end

      #
      # describe_security_groups
      #
      @client.describe_security_groups.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.security_groups.each do |security_group|
          struct = OpenStruct.new(security_group.to_h)
          struct.type = 'security_group'
          struct.arn = security_group.group_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_network_interfaces
      #
      @client.describe_network_interfaces.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.network_interfaces.each do |network_interface|
          struct = OpenStruct.new(network_interface.to_h)
          struct.type = 'network_interface'
          struct.arn = network_interface.network_interface_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_network_acls
      #
      @client.describe_network_acls.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.network_acls.each do |network_acl|
          struct = OpenStruct.new(network_acl.to_h)
          struct.type = 'network_acl'
          struct.arn = network_acl.network_acl_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_subnets
      #
      @client.describe_subnets.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.subnets.each do |subnet|
          struct = OpenStruct.new(subnet.to_h)
          struct.type = 'subnet'
          struct.arn = subnet.subnet_arn

          resources.push(struct.to_h)
        end
      end

      #
      # describe_addresses
      #
      @client.describe_addresses.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.addresses.each do |address|
          struct = OpenStruct.new(address.to_h)
          struct.type = 'eip_address'
          struct.arn = address.allocation_id

          resources.push(struct.to_h)
        end
      end

      #
      # describe_nat_gateways
      #
      @client.describe_nat_gateways.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.nat_gateways.each do |gateway|
          struct = OpenStruct.new(gateway.to_h)
          struct.type = 'nat_gateway'
          struct.arn = gateway.nat_gateway_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_internet_gateways
      #
      @client.describe_internet_gateways.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.internet_gateways.each do |gateway|
          struct = OpenStruct.new(gateway.to_h)
          struct.type = 'internet_gateway'
          struct.arn = gateway.internet_gateway_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_route_tables
      #
      @client.describe_route_tables.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.route_tables.each do |table|
          struct = OpenStruct.new(table.to_h)
          struct.type = 'route_table'
          struct.arn = table.route_table_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_images
      #
      @client.describe_images(image_params).each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.images.each do |image|
          struct = OpenStruct.new(image.to_h)
          struct.type = 'image'
          struct.arn = image.image_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_snapshots
      #
      @client.describe_snapshots(snapshot_params).each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.snapshots.each do |snapshot|
          struct = OpenStruct.new(snapshot.to_h)
          struct.type = 'snapshot'
          struct.arn = snapshot.snapshot_id # no true ARN
          struct.create_volume_permissions = @client.describe_snapshot_attribute({
                                                                                   attribute: 'createVolumePermission',
                                                                                   snapshot_id: snapshot.snapshot_id
                                                                                 }).create_volume_permissions.map(&:to_h)

          resources.push(struct.to_h)
        end
      end

      #
      # describe_flow_logs
      #
      @client.describe_flow_logs.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.flow_logs.each do |flow_log|
          struct = OpenStruct.new(flow_log.to_h)
          struct.type = 'flow_log'
          struct.arn = flow_log.flow_log_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_volumes
      #
      @client.describe_volumes.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.volumes.each do |volume|
          struct = OpenStruct.new(volume.to_h)
          struct.type = 'volume'
          struct.arn = volume.volume_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_vpn_gateways
      #
      @client.describe_vpn_gateways.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.vpn_gateways.each do |gateway|
          struct = OpenStruct.new(gateway.to_h)
          struct.type = 'vpn_gateway'
          struct.arn = gateway.vpn_gateway_id # no true ARN

          resources.push(struct.to_h)
        end
      end

      #
      # describe_vpc_peering_connections
      #
      @client.describe_vpc_peering_connections.each_with_index do |response, page|
        log(response.context.operation_name, page)

        response.vpc_peering_connections.each do |peer|
          struct = OpenStruct.new(peer.to_h)
          struct.type = 'peering_connection'
          struct.arn = peer.vpc_peering_connection_id # no true ARN

          resources.push(struct.to_h)
        end
      end
    end

    resources
  end
end
