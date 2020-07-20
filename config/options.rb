class Parser
  Options = Struct.new(
    :regions,
    :services,
    :config_file,
    :output_file,
    :output_format,
    :disable_multi_threading,
    :skip_slow,
    :stream_output,
    :verbose,
    :debug
  )

  def self.parse(options)
    begin
      unless (options & ['-h', '--help']).any?
        aws_regions = ['global'].concat(Aws::EC2::Client.new.describe_regions.regions.map(&:region_name))
      end
    rescue Aws::Errors::ServiceError => e
      puts "\nAWS Error: #{e.code}\n\n"
      exit
    end

    aws_services = YAML.load(File.read('./config/services.yaml'), symbolize_names: true)

    args = Options.new(
      aws_regions,
      aws_services.map { |service| service[:name] },
      nil,
      'output.json',
      'aws',
      false,
      false,
      false,
      false,
      false
    )

    opt_parser = OptionParser.new do |opts|
      opts.banner = "\n\x1b[32mAWS Recon\x1b[0m - AWS Inventory Collector\n\nUsage: #{$0} [options]"

      # regions
      opts.on('-r', '--regions[=REGIONS]', 'Regions to scan, separated by comma (default: all)') do |regions|
        next if regions.downcase == 'all'

        args.regions = args.regions.filter { |region| regions.split(',').include?(region) }
      end

      # regions to skip
      opts.on('-n', '--not-regions[=REGIONS]', 'Regions to skip, separated by comma (default: none)') do |regions|
        next if regions.downcase == 'all'

        args.regions = args.regions.filter { |region| !regions.split(',').include?(region) }
      end

      # services
      opts.on('-s', '--services[=SERVICES]', 'Services to scan, separated by comma (default: all)') do |services|
        next if services.downcase == 'all'

        svcs = services.split(',')
        args.services = aws_services.map { |service| service[:name] if svcs.include?(service[:name]) || svcs.include?(service[:alias]) }.compact # rubocop:disable Layout/LineLength
      end

      # services to skip
      opts.on('-x', '--not-services[=SERVICES]', 'Services to skip, separated by comma (default: none)') do |services|
        next if services.downcase == 'all'

        svcs = services.split(',')
        args.services = aws_services.map { |service| service[:name] unless svcs.include?(service[:name]) || svcs.include?(service[:alias]) }.compact # rubocop:disable Layout/LineLength
      end

      # config file
      opts.on('-c', '--config[=CONFIG]', 'Specify config file for services & regions (e.g. config.yaml)') do |config|
        args.config_file = config
      end

      # output file
      opts.on('-o', '--output[=OUTPUT]', 'Specify output file (default: output.json)') do |output|
        args.output_file = output
      end

      # output format
      opts.on('-f', '--format[=FORMAT]', 'Specify output format (default: aws)') do |file|
        if %w[aws custom].include?(file.downcase)
          args.output_format = file.downcase
        end
      end

      # disable multi-threading
      opts.on('-1', '--disable-multi-threading', 'Disable multi-threading (default: false)') do
        args.disable_multi_threading = true
      end

      # skip slow operations
      opts.on('-z', '--skip-slow', 'Skip slow operations (default: false)') do
        args.skip_slow = true
      end

      # stream output (forces JSON lines, doesn't output handled warnings or errors )
      opts.on('-t', '--stream-output', 'Stream JSON lines to stdout (default: false)') do
        args.output_file = nil
        args.verbose = false
        args.debug = false
        args.stream_output = true
      end

      # verbose
      opts.on('-v', '--verbose', 'Output client progress and current operation') do
        args.verbose = true unless args.stream_output
      end

      # debug
      opts.on('-d', '--debug', 'Output debug with wire trace info') do
        unless args.stream_output
          args.debug = true
          args.verbose = true
        end
      end

      opts.on('-h', '--help', 'Print this help information') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(options)
    args
  end
end
