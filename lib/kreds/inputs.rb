module Kreds
  module Inputs
    extend self

    def process(value, as:, optional: false)
      return value if optional && value.nil?

      send(as, value)
    end

    private

    def symbol_array(value)
      return value.map(&:to_sym) if value.is_a?(Array) && value.any? && value.all? { _1.is_a?(String) || _1.is_a?(Symbol) }

      raise(Kreds::InvalidArgumentError, "Expected an array of symbols or strings, got `#{value.inspect}`")
    end

    def non_empty_string(value)
      return value if value.is_a?(String) && value.present?

      raise(Kreds::InvalidArgumentError, "Expected a non-empty string, got `#{value.inspect}`")
    end
  end
end
