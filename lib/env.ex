defmodule Env do
  @moduledoc """
  Parse env variables into Either values.
  """

  import TypeClass.Functor
  import TypeClass.Monad
  alias TypeClass.Either

  @spec get(String.t()) :: Either.t()
  def get(key) do
    load() ~>> (&fetch(&1, key))
  end

  defp fetch(_env_status, key) do
    key
    |> System.fetch_env()
    |> Either.to_either()
    |> map_left(fn _ -> "Failed to get key #{key}." end)
  end

  defp load() do
    try do
      DotenvParser.load_file(".env")
      Either.right(:env)
    rescue
      _ -> Either.left("Failed to load env.")
    end
  end
end
