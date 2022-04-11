defmodule :"Elixir.CrwalApp.Repo.Migrations.Change-col-type1" do
  use Ecto.Migration

  def change do
    alter table(:crawl) do
      modify :title, :text
      modify :thumbnail, :text
      modify :link, :text
    end
  end
end
