defmodule CrwalApp.Repo.Migrations.AddLastestTable do
  use Ecto.Migration

  def change do
    alter table(:crawl) do
      add :actor, :string
      add :country, :string
    end
  end
end
