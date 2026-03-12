module Kreds
  module Show
    def show
      Rails.application.credentials.config.to_h
    end
  end
end
