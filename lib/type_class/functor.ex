defmodule TypeClass.Functor do
  @moduledoc """
  Functor TypeClass

  Implements map_left, fmap and <&> as ~>
  """

  alias TypeClass.Either, as: Either

  #
  # Either implementation
  #
  @doc """

    fmap is implemented for the following typeclasses:
    - list
    - either
    
    ## Type
    fmap :: Functor a -> (a -> b) -> Functor b

    maps a function into a functor

    fmap(functor_value, function)

  """
  @spec fmap(Either.t(), fun()) :: Either.t()
  def fmap({:left, value}, _func), do: Either.left(value)
  def fmap({:right, value}, func), do: func.(value) |> Either.right()

  #
  # List implementation
  #

  def fmap([], _func), do: []
  def fmap([x | y], func), do: Enum.map([x | y], func)

  @doc """
  map_left is implemented for the following typeclasses:
  - Either.t

  Maps function over the first functor in a bifunctor

  ## Type
  map_left :: BiFunctor a b -> (a -> c) -> BiFunctor c b

   ## Examples

      iex> Either.left(10) ~> fn x -> x + 1 end
      {:left, 11}

      iex> Either.right(10) ~> fn x -> x + 1 end
      {:right, 10}

  """
  @spec map_left(Either.t(), fun()) :: Either.t()
  def map_left({:left, val}, func), do: Either.left(func.(val))
  def map_left({:right, val}, _func), do: Either.right(val)

  @spec map_error(Either.t(), String.t()) :: Either.t()
  def map_error({:right, val}, _error_msg), do: Either.right(val)
  def map_error({:left, _error}, error_msg), do: Either.left(error_msg)
end
