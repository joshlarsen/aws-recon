# frozen_string_literal: true

SERVICES_CONFIG_FILE = File.join(File.dirname(__FILE__), 'services.yaml').freeze

module AwsRecon
  class CLI
    def initialize
      # parse options
      @options = Parser.parse ARGV.length < 1 ? %w[-h] : ARGV

      # timing
      @starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # AWS account id
      @account_id = Aws::STS::Client.new.get_caller_identity.account

      # AWS services
      @aws_services = YAML.load(File.read(SERVICES_CONFIG_FILE), symbolize_names: true)

      # User config services
      if @options.config_file
        user_config = YAML.load(File.read(@options.config_file), symbolize_names: true)

        @services = user_config[:services]
        @regions = user_config[:regions]
      else
        @regions = @options.regions
        @services = @options.services
      end

      # collection
      @resources = []

      # formatter
      @formatter = Formatter.new

      unless @options.stream_output
        puts "\nStarting collection with #{@options.threads} threads...\n"
      end
    end

    #
    # collector wrapper
    #
    def collect(service, region)
      mapper = Object.const_get(service.name)
      resources = mapper.new(@account_id, service.name, region, @options)

      collection = resources.collect.map do |resource|
        if @options.output_format == 'custom'
          @formatter.custom(@account_id, region, service, resource)
        else
          @formatter.aws(@account_id, region, service, resource)
        end
      end

      # write resources to stdout
      if @options.stream_output
        collection.each do |item|
          puts item.to_json
        end
      end

      # add resources to resources array for output to file
      @resources.concat(collection) if @options.output_file
    end

    #
    # main wrapper
    #
    def start(_args)
      #
      # global services
      #
      @aws_services.map { |x| OpenStruct.new(x) }.filter { |s| s.global }.each do |service|
        # user included this service in the args
        next unless @services.include?(service.name)

        # user did not exclude 'global'
        next unless @regions.include?('global')

        collect(service, 'global')
      end

      #
      # regional services
      #
      @regions.filter { |x| x != 'global' }.each do |region|
        Parallel.map(@aws_services.map { |x| OpenStruct.new(x) }.filter { |s| !s.global }.each, in_threads: @options.threads) do |service|
          # some services aren't available in some regions
          skip_region = service&.excluded_regions&.include?(region)

          # user included this region in the args
          next unless @regions.include?(region) && !skip_region

          # user included this service in the args
          next unless @services.include?(service.name) || @services.include?(service.alias) # rubocop:disable Layout/LineLength

          collect(service, region)
        end
      end
    rescue Interrupt # ctrl-c
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @starting

      puts "\nStopped early after \x1b[32m#{elapsed.to_i}\x1b[0m seconds.\n"
    ensure
      # write output file
      if @options.output_file
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @starting

        puts "\nFinished in \x1b[32m#{elapsed.to_i}\x1b[0m seconds. Saving resources to \x1b[32m#{@options.output_file}\x1b[0m.\n\n"

        File.write(@options.output_file, @resources.to_json)
      end
    end
  end
end
