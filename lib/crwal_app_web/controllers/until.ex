defmodule Untils do
  def main(input) do
    list =
      total_page(input)
      |> fetch_document(input)
      |> List.flatten()

    total = Enum.count(list)
    time = getTime()

    res = %{
      total: total,
      created_at: time,
      list_films: list
    }

    encode_json(res, "film")
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
      Enum.map(1..total_page, fn x ->
        if x == 1 do
          response
        else
          response <> "page/" <> Integer.to_string(x) <> "/"
        end
      end)

    list =
      Enum.with_index(pages, fn ele, idx ->
        fetch_items(ele, idx)
      end)

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

            if String.contains?(second, "http") and String.contains?(second, "//") do
              second
            else
              nil
            end
          end)
          |> Enum.filter(fn x -> x !== nil end)
          |> List.to_string()

        # return
        %{
          page: idx + 1,
          title: title,
          link: link,
          full_series: curr_ep == full_ep,
          number_of_episode: String.to_integer(curr_ep),
          thumbnail: thumbnail_url,
          year: year
        }
      end)

    item
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
