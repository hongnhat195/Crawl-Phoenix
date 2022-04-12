defmodule CrwalAppWeb.CrawlController do
  use CrwalAppWeb, :controller
  alias Untils
  alias CrwalApp
  alias CrwalApp.Repo
  alias CrwalApp.Crawl

  import Ecto.Query, warn: false, only: [from: 2]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"data" => %{"url" => url}}) do
    if File.exists?("priv/static/film.json") do
      render(conn, "action.html")
    else
      Untils.main(url)
      render(conn, "action.html")
    end
  end

  def download(conn, _params) do
    path = Application.app_dir(:crwal_app, "priv/static/film.json")
    send_download(conn, {:file, path})
  end

  def show(conn, _params) do
    if Repo.all(Crawl) == [] do
      {:ok, list} = File.read("priv/static/film.json")
      IO.inspect(list)
      {:ok, list1} = Jason.decode(list, keys: :atoms)
      list_film = list1[:list_films]
      IO.inspect(list_film)
      Repo.insert_all(Crawl, list_film)
    end

    pagination_page(conn, %{"pagination" => "1"})
  end

  def pagination_page(conn, %{"pagination" => pagination}) do
    pagination = String.to_integer(pagination)

    max_pages = Repo.all(max_page()) |> Enum.at(0) |> String.to_integer()
    res = query_film(pagination)

    IO.inspect(max_pages, label: "show.html +++++++++++++++++++++++++: ")
    render(conn, "show.html", list_films: res, pagination: pagination, max_pages: max_pages)
  end

  defp query_film(pagination) do
    query =
      from u in "crawl",
        where: u.page == ^pagination,
        select: [
          u.page,
          u.title,
          u.link,
          u.thumbnail,
          u.number_of_episode,
          u.year,
          u.full_series
        ]

    Repo.all(query)
  end

  defp max_page() do
    from p in "crawl", where: p.page > 38, select: min(type(p.page, :string))
  end
end
