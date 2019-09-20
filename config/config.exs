# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pyromoney,
  ecto_repos: [Pyromoney.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :pyromoney, PyromoneyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I2ZW/2BfkqHq1tm0kTuLGWZO9dTkkwfXx0lSOmIuvozfRc0HgPDm39859kM77MsD",
  render_errors: [view: PyromoneyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Pyromoney.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
