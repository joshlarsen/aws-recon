# frozen_string_literal: true

module AwsRecon
end

require 'aws_recon/lib/patch.rb'
String.include PolicyStringParser

require 'parallel'
require 'ostruct'
require 'optparse'
require 'yaml'
require 'csv'
require 'aws-sdk'
require 'aws_recon/options.rb'
require 'aws_recon/lib/mapper.rb'
require 'aws_recon/lib/formatter.rb'
require 'aws_recon/collectors.rb'

require 'aws_recon/version'
require 'aws_recon/aws_recon'
