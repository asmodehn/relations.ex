defmodule ExampleTest do
  use ExUnit.Case

  require Example

  use ExUnitProperties

  # doctest Example

  # reltest Example, &equal/2

  property "generator property test" do
    check all(v <- Example.gen()) do
      %Example{int: i} = v
      assert is_integer(i)
    end
  end

  require Relations.Properties

  describe "&Example.congruent?/2 for Example.gen()" do
    Relations.Properties.reflexive(Example.gen(), &Example.congruent?/2, descr: "is reflexive")
    Relations.Properties.symmetric(Example.gen(), &Example.congruent?/2, descr: "is symmetric")
    Relations.Properties.transitive(Example.gen(), &Example.congruent?/2, descr: "is transitive")
  end

  require Relations

  Relations.reltest(Example)
  # Relations.check_equivalence &Example.congruent?/2, for: Example.all()
  # TODO MAYBE ?
end
