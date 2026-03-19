module Kreds
  module Show
    def show
      Rails.application.credentials.config.to_h
    end

    def env_show
      show[Rails.env.to_sym].to_h
    end
  end
end
