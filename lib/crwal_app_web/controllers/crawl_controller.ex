defmodule CrwalAppWeb.CrawlController do
  use CrwalAppWeb, :controller
  alias Untils
  alias CrwalApp
  alias CrwalApp.Repo
  alias CrwalApp.Crawl

  import Ecto.Query, warn: false

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

    pagination_page(conn, %{"pagination" => 1})
  end

  def pagination_page(conn, params) do
    IO.inspect(params, label: "Pagination: ")
    %{"pagination" => pagination} = params
    pagination = String.to_integer(pagination)

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

    res = Repo.all(query)
    # IO.inspect(res, label: "show.html +++++++++++++++++++++++++=")
    render(conn, "show.html", list_films: res, pagination: pagination)
  end
end
