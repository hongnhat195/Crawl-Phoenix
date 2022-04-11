defmodule :"Elixir.CrwalApp.Repo.Migrations.Col-type-text" do
  use Ecto.Migration

  def change do
    alter table(:crawl) do
      modify :title, :text
      modify :thumbnail, :text
      modify :link, :text
    end
  end
end
