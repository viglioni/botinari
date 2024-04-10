defmodule TypeClass.Either do
  @moduledoc """
  Either TypeClass

  Either value can be: {:right, val} or {:left, error}
  """

  @type t :: {:right, any()} | {:left, any()}

  # generators
  @doc """
  left :: T -> Either T _
  """
  @spec left(any()) :: t()
  def left(val), do: {:left, val}

  @doc """
  right :: T -> Either _ T
  """
  @spec right(any()) :: t()
  def right(val), do: {:right, val}

  @spec return(any()) :: t()
  def return(val), do: right(val)

  # checkers

  @doc """
  is_right :: Either A B -> Boolean
  """
  @spec is_right(t()) :: boolean()
  def is_right({:right, _}), do: true
  def is_right({:left, _}), do: false

  @doc """
  is_left :: Either A B -> Boolean
  """
  @spec is_left(t()) :: boolean()
  def is_left({:right, _}), do: false
  def is_left({:left, _}), do: true
end
