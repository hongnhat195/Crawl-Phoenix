defmodule CrwalApp.Repo.Migrations.ReferenceCountry do
  use Ecto.Migration

  def change do
    rename table(:actor), to: table(:country)

    alter table(:crawl) do
      add :country_id, references(:country)
    end
  end
end
