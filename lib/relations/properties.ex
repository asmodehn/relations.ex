defmodule Relations.Properties do

  @moduledoc ~S"""
  
  Module gathering all properties tests.

  For each property there is a check macro for the code itself, 
  and a function returning a quoted block with the property and a description string.
  """


  def string_or_inspect(smth) do
    if is_nil(String.Chars.impl_for(smth)) do
      Kernel.inspect(smth)
    else
      String.Chars.to_string(smth)
    end
  end


  def symmetric_prop_descr(generator, relation) do

    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)


    "#{rel_str} is symmetric for #{gen_str}" 

  end

  def symmetric_inspect_descr(value, relation) do
    
    rel_str = string_or_inspect(relation)

    value_str = string_or_inspect(value)

    "#{rel_str}.(#{value_str}, #{value_str}) ? "

  end


  defmacro symmetric(generator, relation, [inspect: inspect] \\ [inspect: false]) do




    quoted_check = if inspect do
      quote do
check all(r <- unquote(generator) ) do

            IO.write(Relations.Properties.symmetric_inspect_descr(r, unquote(relation)))
            res = unquote(relation).(r, r)
            IO.inspect(res)
            assert res
      end
          end
else
  quote do
            check all(r <- unquote(generator) ) do
            assert unquote(relation).(r, r)
          end
        end
      end


    
      quote do
        property Relations.Properties.symmetric_prop_descr(unquote(generator), unquote(relation)) do
        unquote(quoted_check)
        end
      end


  end







defmacro reflexive(generator, relation) do

  rel_str = if is_nil(String.Chars.impl_for(relation))do
    Kernel.inspect(relation)
  else
    String.Chars.to_string(relation)
  end

  gen_str = if is_nil(String.Chars.impl_for(generator))do
    Kernel.inspect(generator)
  else
    String.Chars.to_string(generator)
  end

	quote location: :keep do
      property "#{unquote(rel_str)} is reflexive for #{unquote(gen_str)}" do
        check all(
                a <- unquote(generator),
                b <- unquote(generator)
              ) do
          assert unquote(relation)(a, b) === unquote(relation)(b, a)
        end
      end
  end
end

def transitive(module, relation) do
	      quote do  # TODO : location :keep ??
      
      property "#{unquote(relation)} is transitive" do
        # Note: For praticallity we may want to generate only one rational, and "perturbate " it to test equality transitivity.
        check all(
                b <- unquote(module).generator(),
                a <- unquote(module).generator(),
                c <- unquote(module).generator()
              ) do
          # ap <- integer(),
          # cp <- integer() do
          #   a = Rational.perturbate(b, ap)
          #   c = Rational.perturbate(b, ac)
          assert not (apply(unquote(module), unquote(relation), [a, b]) and apply(unquote(module), unquote(relation), [b, c]) and
                        not apply(unquote(module), unquote(relation), [a, c]))
        end
      end
  end
end




  # def all(properties) when is_list(properties) do
  #   properties |> Enum.into(%{}) |> all()
  # end


  # def all(properties) when is_map(properties) do
  #   symm = properties |> Map.get(:symmetric)
  #   refl = properties |> Map.get(:reflexive)
  #    tran = properties |> Map.get(:transitive)

  #   # ensure the list is empty
  #   unknown_props = Map.drop(properties, [:symmetric, :reflexive, :transitive]) 
  #   if unknown_props != %{} do
  #     # TODO : specific exeption
  #     raise RuntimeError, message: "#{unknown_props} contains unknown properties"
  #   end

  #   fn (module, relation) ->
  #     if symm do
  #       symmetric(module, relation)
  #     end
  #     if refl do
  #       reflexive(module.generator(), relation)
  #     end
  #     if tran do
  #       transitive(module, relation)
  #     end
  #   end

  # end


end