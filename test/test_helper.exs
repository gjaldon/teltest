Logger.configure(level: :warn)
ExUnit.start()

Mix.Task.run "ecto.migrate", ~w(-r Telnyx.Repo --quiet)
Ecto.Adapters.SQL.Sandbox.mode(Telnyx.Repo, :manual)
