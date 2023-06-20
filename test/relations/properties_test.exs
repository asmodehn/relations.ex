defmodule Relations.PropertiesTest do
  use ExUnit.Case
  doctest Relations.Properties

  alias Relations.Properties

  use ExUnitProperties

  describe "empty/2" do
    # sum of two integers cannot be more than the max -> empty relation
    Properties.empty(StreamData.integer(1..8), fn l, r -> l + r > 16 end)

    # more simple, yet non-trivial examples ?
  end

  describe "universal/2" do
    # absolute diff of two integers is always positive -> universal relation
    Properties.universal(StreamData.integer(1..8), fn l, r -> abs(l - r) >= 0 end)

    # more simple, yet non-trivial examples ?
  end

  describe "identity/2" do
    # equal is the identity relation in Elixir for integer -> identity relation
    Properties.identity(StreamData.integer(1..8), &Kernel.===/2)

    # more simple, yet non-trivial examples ?
  end

  describe "reflexive/2" do
    # Equality on integers is an equivalence relation so it is reflexive
    Properties.reflexive(StreamData.integer(), &Kernel.==/2)

    # divisibility is reflexive
    Properties.reflexive(
      StreamData.integer() |> StreamData.filter(fn x -> x != 0 end),
      fn l, r -> rem(l, r) == 0 end,
      inspect: false
    )

    # more simple, yet non-trivial examples ?
  end

  describe "symmetric/2" do
    # Equality on integers is an equivalence relation so it is symmetric
    Properties.symmetric(StreamData.integer(), &Kernel.==/2)

    #
    # divisibility is NOT symmetric => This should error on `mix test` if enabled
    #
    # Properties.symmetric(
    #   StreamData.integer() |> StreamData.filter(fn x -> x != 0 end),
    #   fn l, r -> rem(l, r) == 0 end,
    #   inspect: true
    # )

    require Integer

    # symmetric "x and y are odd" relation, by "and" symmetry ( also works when "and" breaks out early )
    Properties.symmetric(
      StreamData.integer(),
      fn l, r -> Integer.is_odd(l) and Integer.is_odd(r) end,
      inspect: false
    )

    # more simple, yet non-trivial examples ?
  end

  describe "transitive/2" do
    # Equality on integers is an equivalence relation so it is transitive
    Properties.transitive(StreamData.integer(), &Kernel.==/2)

    # divisibility is transitive
    Properties.transitive(
      StreamData.integer() |> StreamData.filter(fn x -> x != 0 end),
      fn l, r -> rem(l, r) == 0 end,
      inspect: false
    )

    # order relation is transitive on integers
    Properties.transitive(StreamData.integer(), &Kernel.>/2, inspect: false)

    # more simple, yet non-trivial examples ?
  end

  describe "antisymmetric/2" do
    # non-strict ordering is anti symmetric
    Properties.antisymmetric(StreamData.integer(), &Kernel.>=/2)
    Properties.antisymmetric(StreamData.integer(), &Kernel.<=/2)
  end

  describe "equivalence/2" do
    # Equality on integers is an equivalence relation
    Properties.equivalence(StreamData.integer(), &Kernel.==/2)
  end
end
