require_relative "kreds/version"

require "rails"

require_relative "kreds/fetch"
require_relative "kreds/show"

module Kreds
  class Error < StandardError; end

  class UnknownKeyError < Error; end
  class BlankValueError < Error; end

  extend ::Kreds::Fetch
  extend ::Kreds::Show
end
