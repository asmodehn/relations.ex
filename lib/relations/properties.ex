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

  def reflexive_prop_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} is reflexive for #{gen_str}"
  end

  def reflexive_inspect_descr(value, relation) do
    rel_str = string_or_inspect(relation)

    value_str = string_or_inspect(value)

    "#{rel_str}.(#{value_str}, #{value_str}) ? "
  end

  defmacro reflexive(generator, relation, [inspect: inspect] \\ [inspect: false]) do
    quoted_check =
      if inspect do
        quote do
          check all(r <- unquote(generator)) do
            IO.write(Relations.Properties.reflexive_inspect_descr(r, unquote(relation)))
            res = unquote(relation).(r, r)
            IO.inspect(res)
            assert res
          end
        end
      else
        quote do
          check all(r <- unquote(generator)) do
            assert unquote(relation).(r, r)
          end
        end
      end

    quote do
      property Relations.Properties.reflexive_prop_descr(unquote(generator), unquote(relation)) do
        unquote(quoted_check)
      end
    end
  end

  def symmetric_prop_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} is symmetric for #{gen_str}"
  end

  def symmetric_inspect_descr(value_l, value_r, relation) do
    rel_str = string_or_inspect(relation)

    value_l_str = string_or_inspect(value_l)

    value_r_str = string_or_inspect(value_r)

    "#{rel_str}.(#{value_l_str}, #{value_r_str}) => #{rel_str}.(#{value_r_str}, #{value_l_str}) ? "
  end

  defmacro symmetric(generator, relation, [inspect: inspect] \\ [inspect: false]) do
    quoted_check =
      if inspect do
        quote do
          check all(
                  a <- unquote(generator),
                  b <- unquote(generator)
                ) do
            IO.write(Relations.Properties.symmetric_inspect_descr(a, b, unquote(relation)))
            # pass as relation doesnt have to be true for all values...
            res = if unquote(relation).(a, b), do: unquote(relation).(b, a), else: true
            IO.inspect(res)
            assert res
          end
        end
      else
        quote do
          check all(
                  a <- unquote(generator),
                  b <- unquote(generator)
                ) do
            # pass as relation doesnt have to be true for all values...
            if unquote(relation).(a, b), do: unquote(relation).(b, a), else: true
          end
        end
      end

    quote do
      property Relations.Properties.symmetric_prop_descr(unquote(generator), unquote(relation)) do
        unquote(quoted_check)
      end
    end
  end

  def transitive_prop_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} is transitive for #{gen_str}"
  end

  def transitive_inspect_descr(value_l, value_m, value_r, relation) do
    rel_str = string_or_inspect(relation)

    value_l_str = string_or_inspect(value_l)
    value_m_str = string_or_inspect(value_m)

    value_r_str = string_or_inspect(value_r)

    "#{rel_str}.(#{value_l_str}, #{value_m_str}) and #{rel_str}.(#{value_m_str}, #{value_r_str}) => #{rel_str}.(#{value_l_str}, #{value_r_str}) ? "
  end

  defmacro transitive(generator, relation, [inspect: inspect] \\ [inspect: false]) do
    quoted_check =
      if inspect do
        quote do
          check all(
                  a <- unquote(generator),
                  b <- unquote(generator),
                  c <- unquote(generator)
                ) do
            IO.write(Relations.Properties.transitive_inspect_descr(a, b, c, unquote(relation)))
            # pass as relation doesnt have to be true for all values...
            res =
              if unquote(relation).(a, b) and unquote(relation).(b, c),
                do: unquote(relation).(a, c),
                else: true

            IO.inspect(res)
            assert res
          end
        end
      else
        quote do
          check all(
                  a <- unquote(generator),
                  b <- unquote(generator),
                  c <- unquote(generator)
                ) do
            # pass as relation doesnt have to be true for all values...
            if unquote(relation).(a, b) and unquote(relation).(b, c),
              do: unquote(relation).(a, c),
              else: true
          end
        end
      end

    quote do
      property Relations.Properties.transitive_prop_descr(unquote(generator), unquote(relation)) do
        unquote(quoted_check)
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
