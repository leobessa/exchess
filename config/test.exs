use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chess_app, ChessApp.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :info

# Configure your database
config :chess_app, ChessApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "chess_app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
