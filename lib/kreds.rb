require_relative "kreds/version"

module Kreds
  class Error < StandardError; end

  class UnknownKeyError < Error; end
  class BlankValueError < Error; end

  def fetch!(*keys)
    path = []

    keys.reduce(Rails.application.credentials) do |hash, key|
      path << key

      result = hash.fetch(key)

      raise(BlankValueError, "Blank value for: [:#{path.join("][:")}]") if result.blank?
      raise(UnknownKeyError, "Key not found: [:#{path.join("][:")}][:#{keys[path.size]}]") if !result.is_a?(Hash) && keys != path

      result
    end
  rescue KeyError
    raise UnknownKeyError, "Key not found: [:#{path.join("][:")}]"
  end
  module_function :fetch!
end
