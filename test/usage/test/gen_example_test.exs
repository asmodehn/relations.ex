defmodule GenExampleTest do
  use ExUnit.Case

  require Example

  use ExUnitProperties

  property "generator property test" do
    check all(v <- GenExample.all()) do
      # v |> IO.inspect()
      %GenExample{int: i, mod: m} = v
      assert is_integer(i)
      assert is_integer(m) and m > 0 and m <= 8
    end
  end
end
