# frozen_string_literal: true

SERVICES_CONFIG_FILE = File.join(File.dirname(__FILE__), 'services.yaml').freeze

module AwsRecon
  class CLI
    def initialize
      # parse options
      @options = Parser.parse ARGV.empty? ? %w[-h] : ARGV

      # timing
      @starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # AWS account id
      @account_id = Aws::STS::Client.new.get_caller_identity.account

      # AWS services
      @aws_services = YAML.safe_load(File.read(SERVICES_CONFIG_FILE), symbolize_names: true)

      # User config services
      if @options.config_file
        user_config = YAML.safe_load(File.read(@options.config_file), symbolize_names: true)

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

      return unless @options.stream_output

      puts "\nStarting collection with #{@options.threads} threads...\n"
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
    # Format @resources as either
    #
    def formatted_json
      if @options.jsonl
        @resources.map { |r| JSON.generate(r) }.join("\n")
      else
        @resources.to_json
      end
    end

    #
    # main wrapper
    #
    def start(_args)
      #
      # global services
      #
      @aws_services.map { |x| OpenStruct.new(x) }.filter(&:global).each do |service|
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
          next unless @services.include?(service.name) || @services.include?(service.alias)

          collect(service, region)
        end
      end
    rescue Interrupt # ctrl-c
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @starting

      puts "\nStopped early after #{elapsed.to_i} seconds.\n"
    ensure
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @starting

      puts "\nFinished in #{elapsed.to_i} seconds.\n\n"

      # write output file
      if @options.output_file && !@options.s3
        puts "Saving resources to #{@options.output_file}.\n\n"

        File.write(@options.output_file, formatted_json)
      end

      # write output file to S3 bucket
      if @options.s3
        t = Time.now.utc

        s3_full_object_path = "AWSRecon/#{t.year}/#{t.month}/#{t.day}/#{@account_id}_aws_recon_#{t.to_i}.json.gz"

        begin
          # get bucket name (and region if not us-east-1)
          s3_bucket, s3_region = @options.s3.split(':')

          # build IO object and gzip it
          io = StringIO.new
          gzip_data = Zlib::GzipWriter.new(io)
          gzip_data.write(formatted_json)
          gzip_data.close

          # send it to S3
          s3_client = Aws::S3::Client.new(region: s3_region || 'us-east-1')
          s3_resource = Aws::S3::Resource.new(client: s3_client)
          obj = s3_resource.bucket(s3_bucket).object(s3_full_object_path)
          obj.put(body: io.string)

          puts "Saving resources to S3 s3://#{s3_bucket}/#{s3_full_object_path}\n\n"
        rescue Aws::S3::Errors::ServiceError => e
          puts "Error! - could not save output S3 bucket\n\n"
          puts "#{e.message} - #{e.code}\n"
        end
      end
    end
  end
end
