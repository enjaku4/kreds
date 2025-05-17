module Validations
  private

  def validate_keys!(keys)
    raise Kreds::InvalidArgumentError, "No keys provided" if keys.empty?

    return if keys.all? { _1.is_a?(Symbol) || _1.is_a?(String) }

    raise Kreds::InvalidArgumentError, "Credentials Key must be a Symbol or a String"
  end

  def validate_var!(var)
    raise Kreds::InvalidArgumentError, "Environment variable must be a String" if var.present? && !var.is_a?(String)
  end
end
