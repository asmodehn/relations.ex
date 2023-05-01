defmodule CompiledExample do
  @modulus 8

  defstruct int: 0

  use Relations.Generator

  defgen(int: positive_integer())

  # TODO : doctests

  use Relations

  defrel congruent?(l, r), reflexive: true, symmetric: true, transitive: true do
    # congruent if they have same remainder
    rem(l.int, @modulus) == rem(r.int, @modulus)
  end
end
