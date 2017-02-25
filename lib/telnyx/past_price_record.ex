defmodule Telnyx.PastPriceRecord do
  use Ecto.Schema

  schema "past_price_records" do
    field :price, :integer
    field :percentage_change, :float

    belongs_to :product, Telnyx.Product

    timestamps()
  end
end
