defmodule Telnyx.PastPriceRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "past_price_records" do
    field :price, :integer
    field :percentage_change, :float

    belongs_to :product, Telnyx.Product

    timestamps()
  end

  def changeset(past_price, params, new_price) do
    past_price
    |> cast(params, [:price, :product_id])
    |> put_percentage_change(new_price)
  end

  def put_percentage_change(changeset, new_price) do
    if old_price = get_change(changeset, :price) do
      percentage_change = new_price/old_price
      put_change(changeset, :percentage_change, percentage_change)
    else
      changeset
    end
  end
end
