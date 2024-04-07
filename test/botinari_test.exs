defmodule BotinariTest do
  use ExUnit.Case
  doctest Botinari

  test "greets the world" do
    assert Botinari.hello() == :world
  end
end
