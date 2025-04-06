module Kreds
  module Fetch
    # TODO: a method to fetch keys per rails environment
    # TODO: fallback to env variables
    def fetch!(*keys, var: nil)
      path = []

      keys.reduce(Rails.application.credentials) do |hash, key|
        path << key

        result = hash.fetch(key)

        raise(Kreds::Error, "Blank value in credentials: [:#{path.join("][:")}]") if result.blank?
        raise(Kreds::Error, "Credentials key not found: [:#{path.join("][:")}][:#{keys[path.size]}]") if !result.is_a?(Hash) && keys != path

        result
      end
    rescue KeyError
      raise Kreds::Error, "Credentials key not found: [:#{path.join("][:")}]"
    end

    def var!(var)
      value = ENV.fetch(var)

      raise(Kreds::Error, "Blank value in environment variable: #{var.inspect}") if value.blank?

      value
    rescue KeyError
      raise Kreds::Error, "Environment variable not found: #{var.inspect}"
    end
  end
end
