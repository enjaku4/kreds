module Kreds
  module Show
    def show
      Rails.application.credentials.as_json.deep_symbolize_keys
    end
  end
end
