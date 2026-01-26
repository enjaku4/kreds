ENV["RAILS_ENV"] = "test"

require "kreds"
require "byebug"
require "rspec"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!
end

require "#{File.dirname(__FILE__)}/support/test_app"
