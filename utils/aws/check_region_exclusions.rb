# frozen_string_literal: true

#
# Check regional service availability against services.yaml exclusions.
#
# AWS updates the regional service table daily. By checking regional service
# coverage, we can identify regions that should be excluded from AWS Recon
# checks. We exclude non-supported regions because service APIs handle non-
# availability differently. Some will respond with an error that can be handled
# by the errors defined in the AWS Ruby SDK client. Others will fail at the
# network level (i.e. there is no API endpoint even available). We could handle
# those errors and silently fail, but we choose not to so we can identify cases
# where there is a lack of service availability in a particular region.
#
require 'net/http'
require 'json'
require 'yaml'

TS = Time.now.to_i
# AWS Regional services table
URL = "https://api.regional-table.region-services.aws.a2z.com/index.json?timestamp=#{TS}000"

service_to_query = ARGV[0]
region_exclusion_mistmatch = nil

#
# load current AWS Recon regions
#
recon_services = YAML.safe_load(File.read('../../lib/aws_recon/services.yaml'))
abort('Errors loading AWS Recon services') unless recon_services.is_a?(Array)

#
# load current AWS regions (non-gov, non-cn)
#
regions = YAML.safe_load(File.read('regions.yaml'))
abort('Errors loading regions') unless regions['Regions']

all_regions = regions['Regions'].map { |r| r['RegionName'] }

#
# get service/price list from AWS
#
uri = URI(URL)
res = Net::HTTP.get_response(uri)
abort('Error loading AWS services from API') unless res.code == '200'

map = {}

#
# load service region availability
#
data = res.body
json = JSON.parse(data)

#
# query regions for a single service
#
if service_to_query
  single_service_regions = []

  json['prices'].each do |p|
    single_service_regions << p['id'].split(':').last
  end

  single_service_regions.uniq.sort.each { |r| puts r }

  exit 0
end

# iterate through AWS provided services & regions
json['prices'].each do |p|
  at = p['attributes']
  service_name = at['aws:serviceName']
  service_id, service_region = p['id'].split(':')

  # skip this service unless AWS Recon already has exclusions
  next unless recon_services.filter { |s| s['alias'] == service_id }&.length&.positive?

  if map.key?(service_name)
    map[service_name]['regions'] << service_region
  else
    map[service_name] = {
      'id' => service_id,
      'regions' => [service_region]
    }
  end
end

# iterate through the services AWS Recon knows about
map.sort.each do |k, v|
  service_excluded_regions = all_regions.reject { |r| v['regions'].include?(r) }

  aws_recon_service = recon_services.filter { |s| s['alias'] == v['id'] }&.first
  aws_recon_service_excluded_regions = aws_recon_service['excluded_regions'] || []

  # move on if AWS Recon region exclusions match AWS service region exclusions
  next unless service_excluded_regions.sort != aws_recon_service_excluded_regions.sort

  region_exclusion_mistmatch = true

  puts "#{k} (#{v['id']})"

  # determine the direction of the exclusion mismatch
  if (service_excluded_regions - aws_recon_service_excluded_regions).length.positive?
    puts " + missing region exclusion: #{(service_excluded_regions - aws_recon_service_excluded_regions).join(', ')}"
  else
    puts " - unnecessary region exclusion: #{(aws_recon_service_excluded_regions - service_excluded_regions).join(', ')}"
  end
end

# exit code 1 if we have any mismatches
exit 1 if region_exclusion_mistmatch
