defmodule Relations.PropertyTest do
  use ExUnit.Case
  doctest Relations.Property

  alias Relations.Property

  use ExUnitProperties

  Property.expand(
    &Kernel.==/2,
    reflexive: &StreamData.integer/0,
    symmetric: &StreamData.integer/0,
    transitive: &StreamData.integer/0,
    inspect: false
  )
end
