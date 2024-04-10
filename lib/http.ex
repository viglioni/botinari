defmodule Http do
  @moduledoc """
  Make HTTP requests and return Either values.
  """

  alias TypeClass.Either
  import TypeClass.Monad

  @spec get_page_and_parse(String.t()) :: Either.t()
  def get_page_and_parse(url) do
    url
    |> HTTPoison.get()
    |> to_either()
    ~>> (&parse_page/1)
  end

  @spec parse_page(HTTPoison.Response.t()) :: Either.t()
  defp parse_page(%HTTPoison.Response{} = response) do
    response.body
    |> Floki.parse_document()
    |> to_either()
  end

  @spec to_either({:error, any()} | {:ok, any()}) :: Either.t()
  defp to_either({:ok, val}), do: Either.right(val)
  defp to_either({:error, error}), do: Either.left(error)
end
