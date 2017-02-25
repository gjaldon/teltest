use Mix.Config

config :telnyx, Telnyx.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "telnyx_test_dev",
  hostname: "localhost",
  pool_size: 10

config :telnyx, :http_client, Telnyx.HTTPClientAdapter.Hackney
