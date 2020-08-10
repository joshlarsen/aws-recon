#
# Generic wrapper for service clients.
#
# Paging
# ------
# The AWS Ruby SDK has a built-in enumerator in the client response
# object that automatically handles paging large requests. Confirm
# the AWS SDK client call returns a Aws::PageableResponse to take
# advantage of automatic paging.
#
# Retries
# -------
# The AWS Ruby SDK performs retries automatically. We change the
# retry_limit to 9 (10 total requests) and the retry_backoff
# to add 5 seconds delay on each retry for a total max of 55 seconds.
#
class Mapper
  def initialize(service, region, options)
    @service = service
    @region = region
    @options = options
    @thread = Parallel.worker_number || 0

    # build the client interface
    module_name = "Aws::#{service}::Client"

    # incremental delay on retries (seconds)
    retry_delay = 5

    # default is 3 retries, with 15 second sleep in between
    # reset to 9 retries, with incremental backoff
    client_options = {
      retry_mode: 'legacy', # legacy, standard, or adaptive
      retry_limit: 9, # only legacy
      retry_backoff: ->(context) { sleep(retry_delay * context.retries + 1) }, # only legacy
      http_read_timeout: 10
    }

    # regional service
    client_options.merge!({ region: region }) unless region == 'global'

    # organizations only uses us-east-1 in non cn/gov regions
    client_options.merge!({ region: 'us-east-1' }) if service.downcase == 'organizations' # rubocop:disable Layout/LineLength

    # debug with wire trace
    client_options.merge!({ http_wire_trace: true }) if @options.debug

    @client = Object.const_get(module_name).new(client_options)
  end

  private

  def _msg(msg)
    base_msg = ["t#{@thread}", @region, @service]
    base_msg.concat(msg)
  end

  def log(*msg)
    if @options.verbose
      puts _msg(msg).map { |x| "\x1b[32m#{x}\x1b[0m" }.join("\x1b[35m.\x1b[0m")
    end
  end

  def log_error(*msg)
    if @options.verbose
      puts _msg(msg).map { |x| "\x1b[35m#{x}\x1b[0m" }.join("\x1b[32m.\x1b[0m")
    end
  end
end
