# frozen_string_literal: true

# $LOAD_PATH.unshift(File.expand_path(File.join('aws_recon'), __FILE__))

module AwsRecon
end

require 'parallel'
require 'ostruct'
require 'optparse'
require 'yaml'
require 'csv'
require 'pry'
require 'aws-sdk'
require 'aws_recon/options.rb'
require 'aws_recon/lib/mapper.rb'
require 'aws_recon/lib/formatter.rb'
require 'aws_recon/collectors/collectors.rb'

require 'aws_recon/version'
require 'aws_recon/aws_recon'
