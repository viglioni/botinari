defmodule Json do
  @moduledoc """
  Encode/decode json into either.
  """

  alias TypeClass.Either

  @spec encode(any()) :: Either.t()
  def encode(obj) do
    obj |> Jason.encode() |> Either.to_either()
  end

  @spec decode(any()) :: Either.t()
  def decode(obj) do
    obj |> Jason.decode() |> Either.to_either()
  end
end
