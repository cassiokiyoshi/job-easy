Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("ONLYOFFICE_SERVER_URL")
    resource "/rails/active_storage/*", headers: :any, methods: [:get]
  end
end
