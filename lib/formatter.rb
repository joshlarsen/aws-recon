#
# Customize resource format/shape
#
class Formatter
  #
  # Custom
  #
  def custom(account_id, region, service, resource)
    {
      account: account_id,
      name: resource[:arn],
      service: service.name,
      region: region,
      asset_type: resource[:type],
      resource: { data: resource, version: 'v1' },
      timestamp: Time.now.utc
    }
  end

  #
  # Standard AWS
  #
  def aws(account_id, region, service, resource)
    {
      account: account_id,
      service: service.name,
      region: region,
      resource: resource,
      timestamp: Time.now.utc
    }
  end
end
