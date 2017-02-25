defmodule TelnyxTest do
  use ExUnit.Case
  doctest Telnyx

  alias Telnyx.{Repo, Product, PastPriceRecord}

  defmodule HTTPClient do
    def get(_url) do
      Poison.encode! %{
        productRecords: [
          %{id: 1, name: "Nice Chair", price: "$30.25", category: "home-furnishings", discontinued: false},
          %{id: 2, name: "Black & White TV", price: "$43.77", category: "electronics", discontinued: true}
        ]}
    end
  end

  setup do
    Application.put_env(:telnyx, :http_client, HTTPClient)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "update_product_records/0 updates records with outdated prices but same name" do
    old_product = Repo.insert! %Product{id: 1, external_product_id: 1, price: 3000, name: "Nice Chair"}
    Telnyx.update_product_records()
    updated_product = Repo.get Product, 1

    assert updated_product != old_product
    assert updated_product.name == old_product.name
    assert updated_product.price == 3025
  end

  test "update_product_records/0 creates new product if it doesn't exist in our DB and isn't discontinued" do
    assert Repo.all(Product) == []
    Telnyx.update_product_records()
    product = Repo.get_by Product, external_product_id: 1

    assert product.external_product_id == 1
    assert product.price == 3025

    # Product 2 should not exist in our DB since it has been discontinued
    refute Repo.get_by Product, external_product_id: 2
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

  test "past price record has the required fields and associations" do
    product = Repo.insert! %Product{id: 1, external_product_id: 11, price: 200, name: "Test"}
    past_price_record = Repo.insert! %PastPriceRecord{id: 1, price: 250, percentage_change: -0.25, product_id: 1}

    assert past_price_record.price == 250
    assert past_price_record.percentage_change == -0.25

    past_price_record = Repo.preload(past_price_record, :product)
    assert past_price_record.product == product
  end
end
