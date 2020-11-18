class AccessAnalyzer < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_analyzers
    #
    @client.list_analyzers.each_with_index do |response, page|
      log(response.context.operation_name, page)

      # analyzers
      response.analyzers.each do |analyzer|
        struct = OpenStruct.new(analyzer.to_h)
        struct.type = 'analyzer'
        resources.push(struct.to_h)
      end
    end

    resources
  end
end
