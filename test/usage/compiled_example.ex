defmodule CompiledExample do
  @moduledoc false

  @modulus 8

  defstruct int: 0

  use Relations.Generator

  generators do
    def all() do
      ExUnitProperties.gen all(i <- positive_integer()) do
        %CompiledExample{int: i}
      end
    end

    def other(), do: nil
  end

  # TODO : doctests

  use Relations

  defrel congruent?(l, r), reflexive: true, symmetric: true, transitive: true do
    # congruent if they have same remainder
    rem(l.int, @modulus) == rem(r.int, @modulus)
  end
end
