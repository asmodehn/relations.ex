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

  defmacro reflexive(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

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

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Relations.Properties.reflexive_prop_descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
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

  defmacro symmetric(generator, relation, opts \\ [descr: nil, inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

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
            # TODO : more optimal generator ?? CAREFUL : we want to be sure not to miss anything
            if unquote(relation).(a, b), do: unquote(relation).(b, a), else: true
          end
        end
      end

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Relations.Properties.symmetric_prop_descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  # TODO: antisymmetric

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

  defmacro transitive(generator, relation, opts \\ [descr: nil, inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

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
            # TODO : more optimal generator ?? CAREFUL : we want to be sure not to miss anything
            if unquote(relation).(a, b) and unquote(relation).(b, c),
              do: unquote(relation).(a, c),
              else: true
          end
        end
      end

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Relations.Properties.transitive_prop_descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  def describe_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} for #{gen_str}"
  end

  defmacro describe(generator, relation, properties \\ [])
           when is_list(properties)
           when is_map(properties) do
    # If it is a function that needs to be called (because of late definition for instance)
    # then we call it and quote its result.
    # generator = if is_function(unquote(generator), 0), do: quote(unquote(generator)()), else: generator

    inspect = Keyword.get(properties, :inspect, false)

    prop_checks =
      properties
      |> Keyword.drop([:inspect])
      |> Enum.map(fn {k, e} ->
        case {k, e} do
          {:reflexive, true} ->
            quote do:
                    Relations.Properties.reflexive(unquote(generator), unquote(relation),
                      descr: "is reflexive",
                      inspect: unquote(inspect)
                    )

          {:symmetric, true} ->
            quote do:
                    Relations.Properties.symmetric(unquote(generator), unquote(relation),
                      descr: "is symmetric",
                      inspect: unquote(inspect)
                    )

          {:transitive, true} ->
            quote do:
                    Relations.Properties.transitive(unquote(generator), unquote(relation),
                      descr: "is transitive",
                      inspect: unquote(inspect)
                    )

          # TODO : handle false case ? semantics ? need to be compared with not present (ie. no test) 
          unknown ->
            raise RuntimeError, message: "#{Kernel.inspect(unknown)} is not a known property"
        end
      end)

    quote location: :keep do
      describe Relations.Properties.describe_descr(unquote(generator), unquote(relation)) do
        unquote(prop_checks)
      end
    end
  end

  # defmacro describe(generator, relation, properties ) do
  #   IO.inspect([generator, relation, properties])
  # end
end
