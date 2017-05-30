# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chess_app,
  ecto_repos: [ChessApp.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :chess_app, ChessApp.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xn4x4T7fwiQ/vXcPGA6Pp+t9EJ5TbNL2JwIXdidYXN/tnqs8FzRROjo4g7RonNjd",
  render_errors: [view: ChessApp.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: ChessApp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "ChessApp.#{Mix.env}",
  allowed_algos: ["HS256", "HS512"],
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "secret",
  serializer: ChessApp.Account.Serializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
