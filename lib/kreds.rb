require_relative "kreds/version"

require "rails"

require_relative "kreds/inputs"
require_relative "kreds/fetch"
require_relative "kreds/show"

module Kreds
  class Error < StandardError; end
  class InvalidArgumentError < Error; end
  class BlankCredentialsError < Error; end
  class BlankEnvironmentVariableError < Error; end
  class UnknownCredentialsError < Error; end
  class UnknownEnvironmentVariableError < Error; end

  extend ::Kreds::Show
  extend ::Kreds::Fetch
end
