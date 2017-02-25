defmodule Telnyx.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :external_product_id, :integer
      add :price, :integer
      add :name, :string

      timestamps()
    end
  end
end
