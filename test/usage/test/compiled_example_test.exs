defmodule CompiledExampleTest do
  use ExUnit.Case

  require CompiledExample

  use ExUnitProperties

  # doctest CompiledExample

  # reltest CompiledExample, &equal/2

  require Relations.CompiledTests

  Relations.CompiledTests.reltest(CompiledExample)
  # Relations.check_equivalence &CompiledExample.congruent?/2, for: Example.all()
  # TODO MAYBE ?

  # This should trigger a custom Relations.UnknownError on compilation
  # Relations.CompiledTests.reltest(Example)
end
