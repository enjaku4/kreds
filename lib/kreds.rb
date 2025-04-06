require_relative "kreds/version"

require "rails"

require_relative "kreds/fetch"
require_relative "kreds/show"

module Kreds
  class Error < StandardError; end

  extend ::Kreds::Fetch
  extend ::Kreds::Show
end
