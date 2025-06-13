module Kreds
  module Fetch
    def fetch!(*keys, var: nil, &)
      symbolized_keys = Kreds::Inputs.process(
        keys, as: :symbol_array, message: "Expected an array of symbols or strings, got `#{keys.inspect}`"
      )

      path = []

      symbolized_keys.reduce(Kreds.show) do |hash, key|
        path << key
        fetch_key(hash, key, path, symbolized_keys)
      end
    rescue Kreds::BlankCredentialsError, Kreds::UnknownCredentialsError => e
      fallback_to_var(
        e,
        Kreds::Inputs.process(
          var, as: :non_empty_string, optional: true, message: "Expected a non-empty string, got `#{var.inspect}`"
        ),
        &
      )
    end

    def env_fetch!(*keys, var: nil, &)
      fetch!(Rails.env, *keys, var:, &)
    end

    def var!(var, &)
      value = ENV.fetch(
        Kreds::Inputs.process(var, as: :non_empty_string, message: "Expected a non-empty string, got `#{var.inspect}`")
      )

      return raise_or_yield(Kreds::BlankEnvironmentVariableError.new("Blank value in environment variable: #{var.inspect}"), &) if value.blank?

      value
    rescue KeyError
      raise_or_yield(Kreds::UnknownEnvironmentVariableError.new("Environment variable not found: #{var.inspect}"), &)
    end

    private

    def fetch_key(hash, key, path, keys)
      value = hash.fetch(key)

      raise Kreds::BlankCredentialsError, "Blank value in credentials: #{path_to_s(path)}" if value.blank?
      raise Kreds::UnknownCredentialsError, "Credentials key not found: #{path_to_s(path)}[:#{keys[path.size]}]" unless value.is_a?(Hash) || keys == path

      value
    rescue KeyError
      raise Kreds::UnknownCredentialsError, "Credentials key not found: #{path_to_s(path)}"
    end

    def fallback_to_var(error, var, &)
      return raise_or_yield(error, &) if var.blank?

      var!(var, &)
    rescue Kreds::BlankEnvironmentVariableError, Kreds::UnknownEnvironmentVariableError => e
      raise_or_yield(Kreds::Error.new("#{error.message}, #{e.message}"), &)
    end

    def raise_or_yield(error, &)
      block_given? ? yield : raise(error)
    end

    def path_to_s(path)
      "[:#{path.join("][:")}]"
    end
  end
end
