defmodule Telnyx.OmegaApiTest do
  use ExUnit.Case
  doctest Telnyx
  alias Telnyx.OmegaApi

  defmodule HTTPClient do
    def get(_url) do
      Poison.encode! %{
        productRecords: [
          %{id: 123456, name: "Nice Chair", price: "$30.25", category: "home-furnishings", discontinued: false}
        ]}
    end
  end

  setup do
    Application.put_env(:telnyx, :http_client, HTTPClient)
    :ok
  end

  test "records_url/0 returns the pricing records url with correct query params" do
    {:ok, end_date} = Date.new(2017, 2, 25)
    actual = OmegaApi.records_url(end_date)

    # start_date must be 1 month(30 days) before the end date
    assert actual == "https://omegapricinginc.com/pricing/records.json?api_key=SOME_API_KEY&end_date=2017-02-25&start_date=2017-01-26"
  end

  test "records_url/0 uses today as default end_date" do
    [_url, query_params] = OmegaApi.records_url()
      |> String.split("?")
    %{"end_date" => end_date} = URI.decode_query(query_params)
    assert end_date == Date.utc_today() |> Date.to_string()
  end

  test "get_pricing_records/0 returns JSON in decoded form" do
    body = OmegaApi.get_pricing_records()
    assert [%{"id" => 123456}] = body["productRecords"]
  end
end
