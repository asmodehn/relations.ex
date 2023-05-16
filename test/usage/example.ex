defmodule Example do
  @moduledoc false

  @modulus 8

  defstruct int: 0

  use Relations.Generator

  generators do
    defstream(all(int: positive_integer()))
  end

  # TODO : doctests

  def congruent?(l, r) do
    # congruent if they have same remainder
    rem(l.int, @modulus) == rem(r.int, @modulus)
  end
end
