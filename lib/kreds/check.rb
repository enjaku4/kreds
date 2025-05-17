require_relative "validations"

module Kreds
  module Check
    include Validations

    def key?(*keys)
      validate_keys!(keys)

      keys.reduce(Kreds.show) do |hash, key|
        return false unless hash.is_a?(Hash)

        hash.fetch(key.to_sym) { return false }
      end

      true
    end

    def env_key?(*keys)
      key?(Rails.env, *keys)
    end

    def var?(var)
      validate_var!(var)

      ENV.key?(var)
    end
  end
end
