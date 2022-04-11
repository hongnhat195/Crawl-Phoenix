defmodule :"Elixir.CrwalApp.Repo.Migrations.Add-crawl-table" do
  use Ecto.Migration

  def change do
    create table(:crawl) do
      add :page, :string
      add :title, :string
      add :link, :string
      add :full_series, :boolean
      add :year, :integer
      add :number_of_episode, :integer
      add :thumbnail, :string
    end
  end
end
