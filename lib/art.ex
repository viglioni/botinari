defmodule Art do
  @moduledoc """
  Choose random art and get its info.
  """

  use TypedStruct

  alias TypeClass.Either
  import TypeClass.Functor
  import TypeClass.Monad

  typedstruct enforce: true do
    field :title, String.t()
    field :date, String.t()
    field :dimensions, String.t()
    field :description, String.t()
    field :kind, String.t()
    field :technique, String.t()
    field :art_src_url, String.t()
    field :art_page_url, String.t()
  end

  @type html :: Floki.html_tree()

  @collection_page ~s(https://www.portinari.org.br/acervo/obras/)

  ################
  # Get Art page #
  ################

  @spec get_art() :: Either.t()
  def get_art() do
    choose_art() ~>> (&parse_art/1)
  end

  @spec choose_art() :: Either.t()
  defp choose_art() do
    Http.get_page_and_parse(@collection_page)
    |> fmap(&get_art_card/1)
    ~>> (&get_art_page_url/1)
    |> IO.inspect(label: :url)
  end

  @spec parse_art(String.t()) :: Either.t()
  defp parse_art(art_page_url) do
    with {:right, art_page} <- Http.get_page_and_parse(art_page_url),
         {:right, art_src_url} <- get_art_src_url(art_page),
         {:right, properties} <- get_properties(art_page) do
      %{art_src_url: art_src_url, art_page_url: art_page_url}
      |> Map.merge(properties)
      |> (&struct!(__MODULE__, &1)).()
      |> Either.right()
    else
      error -> map_left(error, fn err -> %{error: err, url: art_page_url} end)
    end
  end

  @spec get_art_card(html()) :: any()
  defp get_art_card(parsed_page), do: parsed_page |> Floki.find(".card a") |> hd()

  @spec get_art_page_url(html()) :: Either.t()
  defp get_art_page_url({"a", [_, {"href", url}], _}), do: Either.right(url)
  defp get_art_page_url(_), do: Either.left("Failed getting art page url")

  @spec get_art_src_url(html()) :: Either.t()
  defp get_art_src_url(page) do
    page
    |> Floki.find("a[data-fancybox=gallery] img")
    |> match_src_url()
  end

  @spec match_src_url(html()) :: Either.t()
  defp match_src_url([{"img", [{"src", url}], _}]), do: Either.right(url)
  defp match_src_url(_), do: Either.left("Failed to get art src url.")

  ################
  # Get Art info #
  ################

  @spec get_properties(html()) :: Either.t()
  defp get_properties(parsed_html) do
    with {:right, title} <- title(parsed_html),
         {:right, date} <- date(parsed_html),
         {:right, dimensions} <- dimensions(parsed_html),
         {:right, description} <- description(parsed_html),
         {:right, [kind, technique]} <- kind_and_technique(parsed_html) do
      Either.right(%{
        title: title,
        date: date,
        dimensions: dimensions,
        description: description,
        kind: kind,
        technique: technique
      })
    end
  end

  @spec kind_and_technique(html()) :: Either.t()
  defp kind_and_technique(parsed_html) do
    parsed_html
    |> Floki.find(".highlights a")
    |> Enum.take(2)
    |> Enum.map(&parse_html_line/1)
    |> sequence()
    |> map_error("Failed to parse kind and technique")
  end

  @spec title(html()) :: Either.t()
  defp title(parsed_html) do
    parsed_html
    |> Floki.find("h2")
    |> hd()
    |> parse_html_line()
    |> map_error("Failed to get title")
  end

  @spec date(html()) :: Either.t()
  defp date(parsed_html) do
    parsed_html
    |> Floki.find(".item-date")
    |> hd
    |> parse_html_line()
    |> map_error("Failed to parse date")
  end

  @spec description(html()) :: Either.t()
  defp description(parsed_html) do
    parsed_html
    |> Floki.find("details .limited-text")
    |> Enum.at(1)
    |> parse_html_line()
    |> map_error("Failed to parse description")
  end

  @spec parse_html_line(any()) :: Either.t()
  defp parse_html_line({_, _, [info | _]}), do: Either.right(info)
  defp parse_html_line(_), do: Either.left("Failed to get info in limited-text")

  @spec dimensions(html()) :: Either.t()
  defp dimensions(parsed_html),
    do: parsed_html |> Floki.find(".highlights div") |> Enum.at(2) |> parse_dimensions()

  @spec parse_dimensions(any()) :: Either.t()
  defp parse_dimensions({"div", _, [{"h3", _, _}, dimensions]}),
    do: Either.right(dimensions)

  defp parse_dimensions(_), do: Either.left("Failed to get dimension")
end
