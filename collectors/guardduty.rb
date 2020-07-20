class GuardDuty < Mapper
  #
  # Returns an array of resources.
  #
  # TODO: test live
  #
  def collect
    resources = []

    #
    # list_detectors
    #
    @client.list_detectors.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.detector_ids.each do |detector|
        log(response.context.operation_name, 'get_detector', detector)

        # get_detector
        struct = OpenStruct.new(@client.get_detector({ detector_id: detector }).to_h)
        struct.type = 'detector'
        struct.arn = "arn:aws:guardduty:#{@region}:detector/#{detector}"

        # get_master_account
        struct.master_account = @client.get_master_account({ detector_id: detector }).to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end
end
