defmodule Http do
  @moduledoc """
  Make HTTP requests and return Either values.
  """

  alias TypeClass.Either
  import TypeClass.Monad
  import TypeClass.Functor

  @doc """
  GET url, headers
  Return Either Response.Body Error
  """
  @spec get_body(String.t()) :: Either.t()
  @spec get_body(String.t(), HTTPoison.headers()) :: Either.t()
  def get_body(url, headers \\ []) do
    url
    |> HTTPoison.get(headers)
    |> Either.to_either()
    |> fmap(&res_body/1)
  end

  @doc """
  POST url, body, headers
  Return Either Response.Body Error
  """
  @spec post_body(String.t(), any(), HTTPoison.headers()) :: Either.t()
  def post_body(url, body, headers) do
    url
    |> HTTPoison.post(body, headers)
    |> Either.to_either()
    |> fmap(&res_body/1)
  end

  @doc """
  GET url
  Return parsed html
  """
  @spec get_page_and_parse(String.t()) :: Either.t()
  @spec get_page_and_parse(String.t(), HTTPoison.headers()) :: Either.t()
  def get_page_and_parse(url, headers \\ []) do
    url
    |> HTTPoison.get(headers)
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

  @spec res_body(HTTPoison.Response.t()) :: any()
  defp res_body(%HTTPoison.Response{} = response), do: response.body
end
