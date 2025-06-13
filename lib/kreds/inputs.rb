require "dry-types"

module Kreds
  module Inputs
    extend self

    include Dry.Types()

    TYPES = {
      symbol_array: -> { self::Array.of(self::Coercible::Symbol).constrained(min_size: 1) },
      non_empty_string: -> { self::Strict::String.constrained(min_size: 1) },
      boolean: -> { self::Strict::Bool }
    }.freeze

    def process(value, as:, optional: false, error: Kreds::InvalidArgumentError, message: nil)
      checker = type_for(as)
      checker = checker.optional if optional

      checker[value]
    rescue Dry::Types::CoercionError => e
      raise error, message || e.message
    end

    private

    def type_for(name) = Kreds::Inputs::TYPES.fetch(name).call
  end
end
