defmodule CrwalAppWeb.CrawlController do
  use CrwalAppWeb, :controller
  alias Untils
  alias CrwalApp
  alias CrwalApp.Repo
  alias CrwalApp.Crawl

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
    {:ok, list} = File.read("priv/static/film.json")
    {:ok, list1} = Jason.decode(list, keys: :atoms)
    list_film = list1[:list_film]

    if Repo.all(Crawl) == [] do
      Repo.insert_all(Crawl, list_film)
    end

    render(conn, "action.html")
  end
end
