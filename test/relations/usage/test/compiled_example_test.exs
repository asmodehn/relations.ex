defmodule CompiledExampleTest do
  use ExUnit.Case, async: true

  require CompiledExample

  use ExUnitProperties

  # doctest CompiledExample

  # reltest CompiledExample, &equal/2

  require Relations.Properties

  Relations.Properties.verify(CompiledExample)

  # Relations.check_equivalence &CompiledExample.congruent?/2, for: Example.all()
  # TODO MAYBE ?

  # OR Calling the properties in the CompiledExample.Tests module directly with ExUnit somehow ?
  # ExUnit.run([CompiledExample.Test]) |> IO.inspect()

  # This should trigger a custom Relations.UnknownError on compilation
  # Relations.CompiledTests.reltest(Example)
end
