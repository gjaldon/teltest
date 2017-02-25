defmodule Telnyx.Repo.Migrations.CreatePastPriceRecords do
  use Ecto.Migration

  def change do
    create table(:past_price_records) do
      add :product_id, references(:products)
      add :price, :integer
      add :percentage_change, :float

      timestamps()
    end
  end
end
