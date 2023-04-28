defmodule GenExampleTest do
  use ExUnit.Case

  require Example

  use ExUnitProperties

  property "generator property test" do
    check all(v <- Example.gen()) do
      [int: i, mod: m] = v
      assert is_integer(i)
      assert is_integer(m) and m <= 8
    end
  end
end
