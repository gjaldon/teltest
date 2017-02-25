defmodule Telnyx.OmegaApi do
  @records_url "https://omegapricinginc.com/pricing/records.json"
  @one_month 30
  @adapter Telnyx.HTTPClientAdapter

  def get_pricing_records do
    body = @adapter.get(records_url())
    Poison.decode! body
  end

  def records_url(today \\ Date.utc_today()) do
    start_date = today
      |> Date.to_erl
      |> :calendar.date_to_gregorian_days()
      |> Kernel.-(@one_month)
      |> :calendar.gregorian_days_to_date()
      |> Date.from_erl!
      |> Date.to_string()
    end_date = today |> Date.to_string()
    query_params = URI.encode_query(%{
          api_key: api_key(),
          start_date: start_date,
          end_date: end_date})
    "#{@records_url}?#{query_params}"
  end

  defp api_key do
    Application.get_env(:telnyx, :omega_api_key)
  end
end

defmodule Telnyx.HTTPClientAdapter do
  defmodule Hackney do

    def get(url) do
      case :hackney.request(:get, url, [], "", [:with_body, follow_redirect: true]) do
        {:ok, _status, _headers, body} ->
          body
        {:error, error} ->
          raise "HTTP Client Error: #{error}"
      end
    end
  end

  def get(url) do
    client().get(url)
  end

  def client do
    Application.get_env(:telnyx, :http_client)
  end
end
