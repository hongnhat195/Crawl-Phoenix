defmodule Untils do
  def main(input) do
    list =
      total_page(input)
      |> fetch_document(input)
      |> List.flatten()

    total = Enum.count(list)
    time = getTime()
    list_actor = crawl_actor(input)

    res = %{
      total: total,
      created_at: time,
      list_films: list,
      list_actor: list_actor
    }

    encode_json(res, "film")
  end

  def crawl_actor(url) do
    response = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(response.body)

    document
    |> Floki.find("#mega-menu-1")
    |> Floki.find("li:nth-child(3)")
    |> Floki.find("ul")
    |> Floki.find("li")
    |> Floki.find("a")
    |> Floki.attribute("title")
  end

  def encode_json(input, path) do
    {_status, result} = JSON.encode(input)
    File.write("priv/static/#{path}.json", result)
  end

  def getTime do
    {:ok, time} = :calendar.local_time() |> Calendar.Strftime.strftime("%y-%m-%d %I:%M:%S %p")
    # Calendar.strftime("%y-%m-%d %I:%M:%S %p")
    time
  end

  def total_page(url) do
    response = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(response.body)

    total_page =
      document
      |> Floki.find(".pagination")
      |> Floki.find("li:nth-last-child(2)")
      |> Floki.find("a:first-child")
      |> List.last()
      |> elem(2)
      |> List.last()
      |> String.to_integer()

    total_page
  end

  def fetch_document(total_page, response) do
    pages =
      Enum.map(1..1, fn x ->
        if x == 1 do
          response
        else
          response <> "page/" <> Integer.to_string(x) <> "/"
        end
      end)

    list = Enum.with_index(pages, fn ele, idx -> Untils.fetch_items(ele, idx + 5) end)

    list
  end

  def fetch_items(documentx, idx) do
    response1 = HTTPoison.get!(documentx)
    {:ok, document} = Floki.parse_document(response1.body)

    item =
      document
      |> Floki.find(".movie-item")
      |> Enum.map(fn element ->
        # title
        title_div = Floki.find(element, "div.movie-title-1")
        title = Floki.text(title_div)

        # year
        year = Floki.find(element, "span.movie-title-2") |> Floki.text() |> String.slice(-5..-2)

        year =
          if Regex.match?(~r/^\d+$/, year) do
            year
          else
            "2022"
          end

        # link
        link = Floki.text(Floki.attribute(element, "href"))

        # actor

        # episode
        ribbon = Floki.text(Floki.find(element, "span.ribbon"))
        [curr_ep, full_ep] = ribbon_to_episode(ribbon)

        # thumbnail image
        thumb_div = Floki.find(element, "div.public-film-item-thumb")
        [{_div, thumb_style_list, _nillist}] = thumb_div

        thumbnail_url =
          thumb_style_list
          |> Enum.map(fn x ->
            {_first, second} = x
            second = second |> String.slice(22..-3)

            if String.contains?(second, "http") and String.contains?(second, "//") do
              second
            else
              nil
            end
          end)
          |> Enum.filter(fn x -> x !== nil end)
          |> List.to_string()

        [actor, country] = get_actor_and_country(link)
        # return
        %{
          page: idx + 1,
          title: title,
          link: link,
          full_series: curr_ep == full_ep,
          number_of_episode: String.to_integer(curr_ep),
          thumbnail: thumbnail_url,
          year: year,
          actor: actor,
          country: country
        }
      end)

    item
  end

  def get_actor_and_country(link) do
    detail_crawl = HTTPoison.get!(link)
    {:ok, detail} = Floki.parse_document(detail_crawl.body)

    actor =
      if detail |> Floki.find(".director") != [] do
        detail |> Floki.find(".director") |> Floki.attribute("title") |> Floki.text()
      else
        "N/A"
      end

    country_and_actor = Floki.find(detail, ".movie-dl .movie-dd a")

    country_crawl =
      Enum.map(country_and_actor, fn {_a, list, _tail} ->
        list
      end)
      |> Enum.filter(fn x -> Enum.count(x) == 2 end)
      |> Enum.filter(fn [_href, {title, _country}] -> title == "title" end)

    country =
      if country_crawl == [] do
        "N/A"
      else
        country_crawl |> Enum.at(0) |> Enum.at(-1) |> Tuple.to_list() |> Enum.at(-1)
      end

    [actor, country]
  end

  def ribbon_to_episode(ribbon) do
    str_arr = String.split(ribbon)
    flat_list = List.flatten(Enum.map(str_arr, fn x -> String.split(x, "/") end))

    # a list of strings contains 2 members, the first and second are current and full episode, respectively
    episode =
      Enum.filter(flat_list, fn x ->
        Regex.match?(~r/^\d+$/, x) or x == "??" or Regex.match?(~r/^[\()]\d+$/, x) or
          Regex.match?(~r/^\d+[\)]+$/, x)
      end)

    cond do
      length(episode) == 0 ->
        episode ++ ["1", "1"]

      length(episode) == 1 ->
        episode ++ ["none"]

      length(episode) == 2 and Enum.at(episode, 0) |> String.at(0) == "(" ->
        Enum.map(episode, fn x -> String.replace(x, "(", "") |> String.replace(")", "") end)

      length(episode) == 4 ->
        [_one, _two, three, four] = episode
        [three, four]

      true ->
        episode
    end
  end
end
