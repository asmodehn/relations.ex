defmodule ExampleTest do
  use ExUnit.Case, async: true

  require Example

  use ExUnitProperties

  # doctest Example

  # reltest Example, &equal/2

  property "generator property test" do
    check all(v <- Example.all()) do
      %Example{int: i} = v
      assert is_integer(i)
    end
  end

  require Relations.Properties

  describe "&Example.congruent?/2 for Example.all()" do
    Relations.Properties.reflexive(Example.all(), &Example.congruent?/2, descr: "is reflexive")
    Relations.Properties.symmetric(Example.all(), &Example.congruent?/2, descr: "is symmetric")
    Relations.Properties.transitive(Example.all(), &Example.congruent?/2, descr: "is transitive")
  end
end
