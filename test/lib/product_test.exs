defmodule Telnyx.ProductTest do
  use ExUnit.Case
  alias Telnyx.{PastPriceRecord, Product, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "product has the required fields and associations" do
    product = Repo.insert! %Product{id: 1, external_product_id: 11, price: 200, name: "Test"}
    past_price_record = Repo.insert! %PastPriceRecord{id: 1, price: 250, percentage_change: -0.25, product_id: 1}

    assert product.id == 1
    assert product.external_product_id == 11
    assert product.price == 200
    assert product.name == "Test"
    assert product.updated_at
    assert product.inserted_at

    product = Repo.preload(product, :past_price_records)
    assert product.past_price_records == [past_price_record]
  end
end
