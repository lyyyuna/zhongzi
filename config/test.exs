import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zhongzi, ZhongziWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "EO+4tZ63M+AHTAgCATSLG8VHyLAKXIEDDLO2JXUtDc1An1Yl2R5u6BiYcBlXn/X2",
  server: false

# In test we don't send emails.
config :zhongzi, Zhongzi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Test logging configuration
config :logger, :console,
  format: {Zhongzi.LoggerFormatter, :format},
  metadata: [:request_id, :test]

# Use simple console format for tests
config :zhongzi,
  log_format: :console

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
