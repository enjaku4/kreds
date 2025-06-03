module Kreds
  module Fetch
    def fetch!(*keys, var: nil, &)
      symbolized_keys = Kreds::Inputs.process(keys, as: :symbol_array)

      path = []

      symbolized_keys.reduce(Kreds.show) do |hash, key|
        path << key
        fetch_key(hash, key, path, symbolized_keys)
      end
    rescue Kreds::BlankCredentialsError, Kreds::UnknownCredentialsError => e
      fallback_to_var(e, Kreds::Inputs.process(var, as: :string, optional: true), &)
    end

    def env_fetch!(*keys, var: nil, &)
      fetch!(Rails.env, *keys, var:, &)
    end

    def var!(var, &)
      check_var(Kreds::Inputs.process(var, as: :string), &)
    end

    private

    def fetch_key(hash, key, path, keys)
      value = hash.fetch(key) do
        raise Kreds::UnknownCredentialsError, "Credentials key not found: #{path_to_s(path)}"
      end

      raise Kreds::BlankCredentialsError, "Blank value in credentials: #{path_to_s(path)}" if value.blank?
      raise Kreds::UnknownCredentialsError, "Credentials key not found: #{path_to_s(path)}[:#{keys[path.size]}]" unless value.is_a?(Hash) || keys == path

      value
    end

    def fallback_to_var(error, var, &)
      return raise_or_yield(error, &) if var.blank?

      check_var(var, &)
    rescue Kreds::BlankEnvironmentVariableError, Kreds::UnknownEnvironmentVariableError => e
      raise_or_yield(Kreds::Error.new("#{error.message}, #{e.message}"), &)
    end

    def check_var(var, &)
      value = ENV.fetch(var) do
        return raise_or_yield(Kreds::UnknownEnvironmentVariableError.new("Environment variable not found: #{var.inspect}"), &)
      end

      return raise_or_yield(Kreds::BlankEnvironmentVariableError.new("Blank value in environment variable: #{var.inspect}"), &) if value.blank?

      value
    end

    def raise_or_yield(error, &)
      block_given? ? yield : raise(error)
    end

    def path_to_s(path)
      "[:#{path.join("][:")}]"
    end
  end
end
