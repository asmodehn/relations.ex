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

  #
  #  use Relations
  #
  #  defrel congruent?(l, r),
  #    reflexive: &Generator.all/0,
  #    symmetric: &Generator.all/0,
  #    transitive: &Generator.all/0 do
  #    # congruent if they have same remainder
  #    rem(l.int, @modulus) == rem(r.int, @modulus)
  #  end
  #
  # New syntax
  use Relations.Properties

  @property reflexive: &Generator.all/0
  @property symmetric: &Generator.all/0
  @property transitive: &Generator.all/0
  def congruent?(l, r) do
    # congruent if they have same remainder
    rem(l.int, @modulus) == rem(r.int, @modulus)
  end
end
