module Kreds
  module Check
    def key?(*keys)
      Kreds::Inputs.process(keys, as: :symbol_array).reduce(Kreds.show) do |hash, key|
        return false unless hash.is_a?(Hash)

        hash.fetch(key.to_sym) { return false }
      end

      true
    end

    def env_key?(*keys)
      key?(Rails.env, *keys)
    end

    def var?(var)
      ENV.key?(Kreds::Inputs.process(var, as: :string))
    end
  end
end
