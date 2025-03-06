require_relative "kreds/version"

require "rails"

require_relative "kreds/fetch"

module Kreds
  class Error < StandardError; end

  class UnknownKeyError < Error; end
  class BlankValueError < Error; end

  extend ::Kreds::Fetch
end
