require "dry-types"

module Kreds
  module Inputs
    extend self

    include Dry.Types()

    def process(value, as:, optional: false)
      checker = send(as)
      checker = checker.optional if optional

      checker[value]
    rescue Dry::Types::CoercionError => e
      raise Kreds::InvalidArgumentError, e
    end

    private

    def symbol_array = self::Array.of(self::Coercible::Symbol).constrained(min_size: 1)
    def string = self::Strict::String
    def boolean = self::Strict::Bool
  end
end
