ENV["RAILS_ENV"] = "test"

require "kreds"
require "byebug"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require "#{File.dirname(__FILE__)}/support/test_app"
