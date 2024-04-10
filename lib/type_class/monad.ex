defmodule TypeClass.Monad do
  @moduledoc """
  Monad TypeClass

  Implements >>= as ~>> and sequence
  """
  alias TypeClass.Either, as: Either

  #
  # Either TypeClass implementation
  #

  @doc """
  ~>>
  ## params

  value ~>> function

  where

  value :: Monad a

  function :: a -> Monad b
  """

  def {:left, msg} ~>> _func, do: Either.left(msg)

  def {:right, val} ~>> func do
    with {:right, result} <- func.(val) do
      Either.right(result)
    else
      {:left, error_msg} -> Either.left(error_msg)
      _ -> Either.left("type error: function does not return either")
    end
  end

  @spec sequence([Either.t()]) :: Either.t()
  def sequence([{:left, _} | _] = list), do: either_sequence(list)
  def sequence([{:right, _} | _] = list), do: either_sequence(list)

  defp either_sequence(list), do: Enum.reduce(list, Either.right([]), &either_sequence_fold/2)

  defp either_sequence_fold(_val, _acc = {:left, error}), do: Either.left(error)
  defp either_sequence_fold(_val = {:left, error}, _acc), do: Either.left(error)

  defp either_sequence_fold(_val = {:right, val}, _acc = {:right, list}),
    do: Either.right(Enum.concat(list, [val]))
end
