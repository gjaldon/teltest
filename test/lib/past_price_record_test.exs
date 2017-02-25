defmodule Telnyx.PastPriceRecordTest do
  use ExUnit.Case
  alias Telnyx.{PastPriceRecord, Product, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "past price record has the required fields and associations" do
    product = Repo.insert! %Product{id: 1, external_product_id: 11, price: 200, name: "Test"}
    past_price_record = Repo.insert! %PastPriceRecord{id: 1, price: 250, percentage_change: -0.25, product_id: 1}

    assert past_price_record.price == 250
    assert past_price_record.percentage_change == -0.25

    past_price_record = Repo.preload(past_price_record, :product)
    assert past_price_record.product == product
  end
end
