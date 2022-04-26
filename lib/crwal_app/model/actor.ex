defmodule CrwalApp.Actor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actor" do
    field :name, :string
  end

  def changeset(struct, param \\ %{}) do
    struct |> cast(param, [:name]) |> validate_required([:name])
  end
end
