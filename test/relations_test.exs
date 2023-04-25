defmodule RelationsTest do
  use ExUnit.Case
  doctest Relations

  test "greets the world" do
    assert Relations.hello() == :world
  end
end
