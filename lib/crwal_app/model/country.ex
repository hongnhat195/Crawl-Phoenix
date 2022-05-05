defmodule CrwalApp.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "country" do
    field :name, :string
    # has_many :crawl, Crawl
  end

  def changeset(struct, param \\ %{}) do
    struct |> cast(param, [:name]) |> validate_required([:name])
  end
end
