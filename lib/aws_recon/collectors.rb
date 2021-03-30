# frozen_string_literal: true

# require all collectors
Dir[File.join(__dir__, 'collectors', '*.rb')].sort.each { |file| require file }
