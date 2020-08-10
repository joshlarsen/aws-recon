# require all collectors
Dir[File.join(__dir__, '*.rb')].each { |file| require file }
