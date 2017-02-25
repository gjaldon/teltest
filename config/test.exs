use Mix.Config

config :telnyx, Telnyx.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "telnyx_test_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
