defmodule CrwalAppWeb.CrawlApiController do
  use CrwalAppWeb, :controller
  alias Untils
  alias CrwalApp.Repo
  alias CrwalApp.Crawl
  alias CrwalApp.Country

  import Ecto.Query, warn: false

  # with
  def crawl(conn, %{"url" => url}) do
    case File.exists?("priv/static/film.json") do
      true ->
        conn
        |> put_status(:created)
        |> json(%{})

      false ->
        case HTTPoison.get!(url).status_code == 404 do
          true ->
            conn
            |> put_status(:request_timeout)
            |> json(%{})
            |> halt()

          false ->
            Untils.main(url)

            conn
            |> put_status(:created)
            |> json(%{})
        end
    end
  end

  def download(conn, _params) do
    path = Application.app_dir(:crwal_app, "priv/static/film.json")
    send_download(conn, {:file, path})
  end

  def show(conn, _params) do
    with {:ok, list} <- File.read("priv/static/film.json"),
         {:ok, list1} <-
           Jason.decode(list, keys: :atoms) do
      if(Repo.all(Country) == []) do
        list_country = list1[:list_actor] |> Enum.map(fn x -> %{name: x} end)

        list_film = list1[:list_films]
        CrwalApp.Repo.insert_all(CrwalApp.Country, list_country)
        list_country = Repo.all(Country)

        films =
          Enum.map(list_film, fn x ->
            Enum.map(list_country, fn y ->
              if x[:country] == y.name do
                Map.put(x, :country_id, y.id)
              end
            end)
          end)
          |> List.flatten()
          |> Enum.filter(fn x -> x != nil end)

        Repo.insert_all(Crawl, films |> List.flatten())
      end
    else
      {:error, _enoent} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
        |> halt()
    end

    pagination_page(conn, %{"pagination" => "1", "country" => "", "actor" => ""})
  end

  def pagination_page(conn, %{"pagination" => pagination, "country" => country, "actor" => actor}) do
    # max_pages = Repo.all(max_page()) |> Enum.at(0) |> String.to_integer()
    pagination = String.to_integer(pagination)
    num_of_film = from(f in Crawl, select: f.id) |> Repo.aggregate(:count, :id)
    chunk = 20
    max_page = ceil(num_of_film / chunk)
    offset = chunk * (pagination - 1)
    IO.inspect(chunk)
    IO.inspect(offset)
    IO.inspect(max_page)

    query =
      cond do
        country != "" and actor == "" ->
          Crawl
          |> where([u], u.country == ^country)
          |> select([u], [
            u.page,
            u.title,
            u.link,
            u.thumbnail,
            u.number_of_episode,
            u.year,
            u.full_series,
            u.country,
            u.actor
          ])
          |> limit(^chunk)
          |> offset(^offset)

        country == "" and actor == "" ->
          Crawl
          |> select([u], [
            u.page,
            u.title,
            u.link,
            u.thumbnail,
            u.number_of_episode,
            u.year,
            u.full_series,
            u.country,
            u.actor
          ])
          |> limit(^chunk)
          |> offset(^offset)

        country == "" and actor != "" ->
          actor1 = "#{actor}%"

          Crawl
          |> where([u], ilike(u.actor, ^actor1))
          |> select([u], [
            u.page,
            u.title,
            u.link,
            u.thumbnail,
            u.number_of_episode,
            u.year,
            u.full_series,
            u.country,
            u.actor
          ])
          |> limit(^chunk)
          |> offset(^offset)

        country != "" and actor != "" ->
          actor1 = "#{actor}%"

          Crawl
          |> where([u], u.country == ^country)
          |> where([u], ilike(u.actor, ^actor1))
          |> select([u], [
            u.page,
            u.title,
            u.link,
            u.thumbnail,
            u.number_of_episode,
            u.year,
            u.full_series,
            u.country,
            u.actor
          ])
          |> limit(^chunk)
          |> offset(^offset)
      end

    conn
    |> put_status(:ok)
    |> json(%{list_films: Repo.all(query), pagination: pagination, max_pages: max_page})
  end

  def query_country(conn, _params) do
    query =
      from p in Country,
        select: p.name

    list_country = Repo.all(query)
    conn |> put_status(:ok) |> json(%{list_country: list_country})
  end

  defp max_page() do
    from p in "crawl", where: p.page > 0, select: max(type(p.page, :string))
  end
end
