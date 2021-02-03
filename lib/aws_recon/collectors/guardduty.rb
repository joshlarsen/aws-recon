# frozen_string_literal: true

#
# Collect GuardDuty resources
#
class GuardDuty < Mapper
  #
  # Returns an array of resources.
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
        struct.arn = "arn:aws:guardduty:#{@region}:#{@account}:detector/#{detector}"

        # get_findings_statistics (only active findings)
        struct.findings_statistics = @client.get_findings_statistics({
                                                                       detector_id: detector,
                                                                       finding_statistic_types: ['COUNT_BY_SEVERITY'],
                                                                       finding_criteria: finding_criteria
                                                                     }).finding_statistics.to_h
        # get_findings_statistics (only active findings older than 7 days)
        struct.findings_statistics_aged_short = @client.get_findings_statistics({
                                                                                  detector_id: detector,
                                                                                  finding_statistic_types: ['COUNT_BY_SEVERITY'],
                                                                                  finding_criteria: finding_criteria(7)
                                                                                }).finding_statistics.to_h
        # get_findings_statistics (only active findings older than 30 days)
        struct.findings_statistics_aged_long = @client.get_findings_statistics({
                                                                                 detector_id: detector,
                                                                                 finding_statistic_types: ['COUNT_BY_SEVERITY'],
                                                                                 finding_criteria: finding_criteria(30)
                                                                               }).finding_statistics.to_h

        # get_master_account
        struct.master_account = @client.get_master_account({ detector_id: detector }).master.to_h

        resources.push(struct.to_h)
      end
    end

    resources
  end

  private

  def finding_criteria(days = 1)
    criteria = {
      criterion: {
        'service.archived': { eq: ['false'] }
      }
    }

    if days > 1
      days_ago = (Time.now.to_f * 1000).to_i - (60 * 60 * 24 * 1000 * days) # with miliseconds

      criteria = {
        criterion: {
          'service.archived': { eq: ['false'] },
          'updatedAt': { less_than: days_ago }
        }
      }
    end

    criteria
  end
end
