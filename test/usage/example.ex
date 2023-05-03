defmodule Example do
  @modulus 8

  defstruct int: 0

  use Relations.Generator

  defgen(all(int: positive_integer()))

  # TODO : doctests

  def congruent?(l, r) do
    # congruent if they have same remainder
    rem(l.int, @modulus) == rem(r.int, @modulus)
  end
end
