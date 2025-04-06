module Kreds
  module Fetch
    # TODO: a method to fetch keys per rails environment
    # TODO: fallback to env variables and shortcut method for fetching directly from ENV
    def fetch!(*keys)
      path = []

      keys.reduce(Rails.application.credentials) do |hash, key|
        path << key

        result = hash.fetch(key)

        raise(BlankValueError, "Blank value for: [:#{path.join("][:")}]") if result.blank?
        raise(UnknownKeyError, "Key not found: [:#{path.join("][:")}][:#{keys[path.size]}]") if !result.is_a?(Hash) && keys != path

        result
      end
    rescue KeyError
      raise UnknownKeyError, "Key not found: [:#{path.join("][:")}]"
    end
  end
end
