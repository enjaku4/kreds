require_relative "validations"

module Kreds
  module Fetch
    include Validations

    def fetch!(*keys, var: nil, &)
      validate_keys!(keys)
      validate_var!(var)

      path = []

      keys.reduce(Kreds.show) do |hash, key|
        path << key
        fetch_key(hash, key, path, keys)
      end
    rescue Kreds::BlankCredentialsError, Kreds::UnknownCredentialsError => e
      fallback_to_var(e, var, &)
    end

    def env_fetch!(*keys, var: nil, &)
      fetch!(Rails.env, *keys, var: var, &)
    end

    def var!(var, &)
      validate_var!(var)

      result, success = check_var(var)

      return result if success

      raise_or_yield(result, &)
    end

    private

    def fetch_key(hash, key, path, keys)
      value = hash.fetch(key.to_sym)

      raise Kreds::BlankCredentialsError, "Blank value in credentials: [:#{path.join("][:")}]" if value.blank?
      raise Kreds::UnknownCredentialsError, "Credentials key not found: [:#{path.join("][:")}][:#{keys[path.size]}]" if !value.is_a?(Hash) && keys != path

      value
    rescue KeyError
      raise Kreds::UnknownCredentialsError, "Credentials key not found: [:#{path.join("][:")}]"
    end

    def fallback_to_var(error, var, &)
      if var.present?
        result, success = check_var(var)

        return result if success

        raise_or_yield(Kreds::Error.new([error.message, result.message].join(", ")), &)
      end

      raise_or_yield(error, &)
    end

    def check_var(var)
      value = ENV.fetch(var)

      return [Kreds::BlankEnvironmentVariableError.new("Blank value in environment variable: #{var.inspect}"), false] if value.blank?

      [value, true]
    rescue KeyError
      [Kreds::UnknownEnvironmentVariableError.new("Environment variable not found: #{var.inspect}"), false]
    end

    def raise_or_yield(error, &)
      block_given? ? yield : raise(error)
    end
  end
end
