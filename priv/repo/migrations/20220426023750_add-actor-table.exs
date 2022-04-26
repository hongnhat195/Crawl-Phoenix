defmodule :"Elixir.CrwalApp.Repo.Migrations.Add-actor-table" do
  use Ecto.Migration

  def change do
    create table(:actor) do
      add :name, :string
    end
  end
end
