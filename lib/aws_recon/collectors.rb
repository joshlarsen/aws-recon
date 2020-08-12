# require all collectors
Dir[File.join(__dir__, 'collectors', '*.rb')].each { |file| require file }
