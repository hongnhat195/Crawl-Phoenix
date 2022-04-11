defmodule CrwalApp.Crawl do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crawl" do
    field :page, :integer
    field :title, :string
    field :link, :string
    field :full_series, :boolean
    field :number_of_episode, :integer
    field :year, :string
    field :thumbnail, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:page, :title, :link, :number_of_episode, :full_series, :year, :thumbnail])
    |> validate_required([
      :page,
      :title,
      :link,
      :full_series,
      :number_of_episode,
      :year,
      :thumbnail
    ])
  end
end
