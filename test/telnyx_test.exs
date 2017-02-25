defmodule TelnyxTest do
  use ExUnit.Case
  doctest Telnyx

  alias Telnyx.{Repo, Product, PastPriceRecord}
  import ExUnit.CaptureLog

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

  test "update_product_records/0 updates records with outdated prices but matching names and records previous price" do
    old_product = Repo.insert! %Product{id: 1, external_product_id: 1, price: 3000, name: "Nice Chair"}
    Telnyx.update_product_records()
    updated_product = Repo.get Product, 1

    assert updated_product != old_product
    assert updated_product.name == old_product.name
    assert updated_product.price == 3025

    previous_price = Repo.get_by PastPriceRecord, product_id: 1

    assert previous_price.price == old_product.price
    assert previous_price.percentage_change == updated_product.price/old_product.price
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

  test "update_product_records/0 logs an error message when a product in our DB doesn't match name in Omega" do
    Repo.insert! %Product{id: 1, external_product_id: 1, price: 3000, name: "Nice Table"}
    output = capture_log fn ->
      Telnyx.update_product_records()
    end

    assert output =~ "[error] Product with external_product_id 1 has a name mismatch"
  end
end
