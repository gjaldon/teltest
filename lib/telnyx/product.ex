defmodule Telnyx.Product do
  use Ecto.Schema
  alias Ecto.Changeset

  schema "products" do
    field :external_product_id, :integer
    field :price, :integer
    field :name, :string

    has_many :past_price_records, Telnyx.PastPriceRecord

    timestamps()
  end


  def changeset(model, params) do
    model
    |> Changeset.cast(params, [:price])
  end

end
