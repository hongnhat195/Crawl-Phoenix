defmodule :"Elixir.CrwalApp.Repo.Migrations.Change-col-type" do
  use Ecto.Migration

  def change do
    alter table(:crawl) do
      remove :year
      add :year, :string
    end
  end
end
