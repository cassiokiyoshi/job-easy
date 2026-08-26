ONLYOFFICE_CONFIG = {
  server_url: ENV.fetch("ONLYOFFICE_SERVER_URL"),
  jwt_secret: ENV.fetch("ONLYOFFICE_JWT_SECRET"),
  jwt_header: ENV.fetch("ONLYOFFICE_JWT_HEADER", "Authorization")
}.freeze
