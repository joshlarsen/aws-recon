# frozen_string_literal: true

module AwsRecon
end

# $LOAD_PATH.unshift(File.expand_path(__FILE__))
puts $LOAD_PATH

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
