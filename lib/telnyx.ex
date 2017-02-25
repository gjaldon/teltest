defmodule Telnyx do
  alias Telnyx.{Repo, Product, PastPriceRecord}
  require Logger

  @moduledoc """
  Documentation for Telnyx.
  """

  @doc """
  Updates product records.

  ## Examples

      iex> Telnyx.update_product_records()
      :ok

  """
  def update_product_records do
    pricing_records = Telnyx.OmegaApi.get_pricing_records()["productRecords"]
    Enum.each(pricing_records, fn record ->
      product = Repo.get_by Product, external_product_id: record["id"]
      create_or_update_product(product, record)
    end)
  end

  defp create_or_update_product(nil, record) do
    unless record["discontinued"] do
      params = %{external_product_id: record["id"], name: record["name"], price: decode_price(record["price"])}
      changeset = Product.changeset(%Product{}, params)
      Repo.insert! changeset
    end
  end

  defp create_or_update_product(product, record) do
    new_price = decode_price(record["price"])
    if new_price != product.price && product.name == record["name"] do
      Repo.transaction fn ->
        changeset = Product.changeset(product, %{price: new_price})
        Repo.update! changeset
        params = %{price: product.price, product_id: product.id}
        past_price_cs = PastPriceRecord.changeset(%PastPriceRecord{}, params, new_price)
        Repo.insert! past_price_cs
      end
    end
    if product.name != record["name"] do
      Logger.error "Product with external_product_id #{product.external_product_id} has a name mismatch"
    end
  end

  def decode_price(price) do
    price
    |> String.trim("$")
    |> String.to_float()
    |> Kernel.*(100)
    |> round()
  end
end
