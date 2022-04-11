defmodule :"Elixir.CrwalApp.Repo.Migrations.Page-crawl-col" do
  use Ecto.Migration

  def change do
      alter table(:crawl) do
        remove :page
        add :page,  :integer
      end
  end
end
