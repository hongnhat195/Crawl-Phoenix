defmodule CrwalAppWeb.CrawlController do
  use CrwalAppWeb, :controller
  alias Untils
  alias CrwalApp
  alias CrwalApp.Repo
  alias CrwalApp.Crawl
  alias CrwalApp.Actor
  import Ecto.Query, warn: false, only: [from: 2]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"data" => %{"url" => url}}) do
    if File.exists?("priv/static/film.json") do
      render(conn, "action.html")
    else
      errors_url(conn, url)
      Untils.main(url)
      render(conn, "action.html")
    end

    # Untils.main(url)
    render(conn, "action.html")
  end

  def download(conn, _params) do
    path = Application.app_dir(:crwal_app, "priv/static/film.json")
    send_download(conn, {:file, path})
  end

  def show(conn, _params) do
    case File.read("priv/static/film.json") do
      {:ok, list} ->
        {:ok, list1} = Jason.decode(list, keys: :atoms)

        if Repo.all(Crawl) == [] do
          list_film = list1[:list_films]
          Repo.insert_all(Crawl, list_film)
        end

        if(Repo.all(Actor) == []) do
          list_actor = list1[:list_actor]

          Repo.insert_all(Actor, list_actor)
        end

      {:error, :enoent} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
        |> halt()
    end

    pagination_page(conn, %{"pagination" => "1"})
  end

  def errors_url(conn, url) do
    if HTTPoison.get!(url).status_code == 404 do
      conn
      |> put_flash(:error, "We can not find this url, try again !")
      |> redirect(to: Routes.crawl_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  def pagination_page(conn, %{"pagination" => pagination}) do
    pagination = String.to_integer(pagination)

    max_pages = Repo.all(max_page()) |> Enum.at(0) |> String.to_integer()
    res = query_film(pagination)
    IO.inspect(max_pages, label: "mmax_pages")
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
          u.full_series,
          u.actor,
          u.country
        ]

    Repo.all(query)
  end

  defp max_page() do
    from p in "crawl", select: type(max(p.page), :string)
  end
end
