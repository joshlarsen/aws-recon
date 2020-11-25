#
# Parse and unescape AWS policy document string
#
module PolicyStringParser
  def parse_policy
    JSON.parse(CGI.unescape(self))
  rescue StandardError
    nil
  end
end
