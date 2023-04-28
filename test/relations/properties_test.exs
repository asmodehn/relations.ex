defmodule Relations.PropertiesTest do
  use ExUnit.Case
  doctest Relations.Properties

  alias Relations.Properties


    use ExUnitProperties  

  describe "reflexive/2" do


    # Equality on integers is an equivalence relation so it is reflexive
    Properties.reflexive(StreamData.integer(), &Kernel.==/2)

    # divisibility is reflexive
    Properties.reflexive(StreamData.integer() |> StreamData.filter(fn x -> x != 0 end), 
                         fn l, r -> rem(l, r) == 0 end, inspect: false)

    # more simple, yet non-trivial examples ?

  end

  describe "symmetric/2" do
    
    # Equality on integers is an equivalence relation so it is symmetric
      Properties.symmetric(StreamData.integer(), &Kernel.==/2)

      require Integer

      # symmetric "x and y are odd" relation, by "and" symmetry ( also works when "and" breaks out early )
      Properties.symmetric( StreamData.integer(), fn l, r -> Integer.is_odd(l) and Integer.is_odd(r) end, inspect: false)

    # more simple, yet non-trivial examples ?

  end


  describe "transitive/2" do


    # Equality on integers is an equivalence relation so it is transitive
    Properties.transitive(StreamData.integer(), &Kernel.==/2)


    # divisibility is transitive
    Properties.transitive(StreamData.integer() |> StreamData.filter(fn x -> x != 0 end), 
                         fn l, r -> rem(l, r) == 0 end, inspect: false)


    # order relation is transitive on integers
    Properties.transitive(StreamData.integer(), &Kernel.>/2, inspect: true)


    # more simple, yet non-trivial examples ?

  end


end