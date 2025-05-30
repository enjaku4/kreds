module Kreds
  module Check
    def key?(*keys, check_value: false)
      symbolized_keys = Kreds::Inputs.process(keys, as: :symbol_array)

      symbolized_keys.reduce(Kreds.show) do |hash, key|
        return false unless hash.is_a?(Hash)

        hash.fetch(key) { return false }
      end

      Kreds::Inputs.process(check_value, as: :boolean) ? Kreds.show.dig(*symbolized_keys).present? : true
    end

    def env_key?(*keys, check_value: false)
      key?(Rails.env, *keys, check_value:)
    end

    def var?(var, check_value: false)
      presence = ENV.key?(Kreds::Inputs.process(var, as: :string))
      check_value ? presence && ENV[var].present? : presence
    end
  end
end
