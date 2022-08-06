# frozen_string_literal: true

#
# Collect EFS resources
#
class EFS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # describe_file_systems
    #
    @client.describe_file_systems.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.file_systems.each do |filesystem|
        struct = OpenStruct.new(filesystem.to_h)
        struct.type = 'filesystem'
        struct.arn = filesystem.file_system_arn

        #
        # Describe Backup Policy
        #
        puts(filesystem.file_system_id)
        policy = @client.describe_backup_policy({file_system_id: filesystem.file_system_id})
        struct["backup_policy"] = policy.backup_policy.to_h
        rescue Aws::EFS::Errors::PolicyNotFound => e
          # No backup policy configured for this filesystem. No action neded.
        ensure
          resources.push(struct.to_h)
      end
    end

    resources
  end

  private 

    # not an error
    def suppressed_errors
      %w[
        Aws::EFS::Errors::PolicyNotFound
        ]
    end
end
