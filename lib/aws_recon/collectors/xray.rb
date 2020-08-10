class XRay < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # get_encryption_config
    #
    struct = OpenStruct.new
    struct.config = @client.get_encryption_config.encryption_config.to_h
    struct.type = 'config'

    resources.push(struct.to_h)

    resources
  end
end
