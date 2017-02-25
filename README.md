# Telnyx

## Setup

This application requires a running Postgresql DB.

1. `mix deps.get`
2. `mix ecto.create`
3. `mix ecto.migrate`

## Notes
The main functionality of this project is exposed by `Telnyx.update_product_records/0`. To use it, open iex via `iex -S mix` and then run it like:

```elixir
iex> Telnyx.update_product_records()
```

- Url for sourcing Omega's pricing records is configurable but defaults to `"https://omegapricinginc.com/pricing/records.json"`. It can be configured by passing an env `OMEGA_BASE_RECORDS_URL` to mix when running the application
- Omega's api key is configurable too and defaults to `"SOME_API_KEY"`. You can use the env var `OMEGA_API_KEY` to configure it.
- There are no validations done on the data that we get from the Omega API. The data is expected to have the correct format and have no null values.
- Only dev and test environments have configs.

## Testing

1. `MIX_ENV=test mix ecto.create`
2. `mix test`

## Libraries used
- Ecto and Postgrex - for interfacing with the Postgres DB
- Hackney - HTTP Client used to get data from Omega's API
- Poison - for encoding and decoding JSON
