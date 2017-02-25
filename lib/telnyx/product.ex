defmodule Telnyx.Product do
  use Ecto.Schema

  schema "products" do
    field :external_product_id, :integer
    field :price, :integer
    field :name, :string

    has_many :past_price_records, Telnyx.PastPriceRecord

    timestamps()
  end
end
