require "dry-types"

module Kreds
  module Inputs
    extend self

    include Dry.Types()

    TYPES = {
      symbol_array: -> { self::Array.of(self::Coercible::Symbol).constrained(min_size: 1) },
      string: -> { self::Strict::String },
      boolean: -> { self::Strict::Bool }
    }.freeze

    def process(value, as:, optional: false)
      checker = type_for(as)
      checker = checker.optional if optional

      checker[value]
    rescue Dry::Types::CoercionError => e
      raise Kreds::InvalidArgumentError, e
    end

    private

    def type_for(name) = Kreds::Inputs::TYPES.fetch(name).call
  end
end
