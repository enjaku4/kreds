require "rails"

class TestApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = "dummy_secret_key_base"

  config.credentials.content_path = Rails.root.join("spec/support/credentials.yml.enc")
  config.credentials.key_path = Rails.root.join("spec/support/master.key")
end

Rails.application ||= TestApp.initialize!
