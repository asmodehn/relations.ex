defmodule Relations.Properties.Antisymmetric do
  @moduledoc false

  alias Relations.Properties.Utils

  def quoted_property(generator, relation, opts \\ [descr: nil, inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

    quoted_check =
      quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Relations.Properties.Antisymmetric.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  def quoted_check(generator, relation, inspect: inspect) do
    if inspect do
      quote do
        ExUnitProperties.check all(
                                 a <- unquote(generator),
                                 b <- unquote(generator)
                               ) do
          IO.write(Relations.Properties.Antisymmetric.inspect_descr(a, b, unquote(relation)))
          # pass as relation doesnt have to be true for all values...
          res = if unquote(relation).(a, b) and unquote(relation).(b, a), do: a === b, else: true
          IO.inspect(res)
          assert res
        end
      end
    else
      quote do
        ExUnitProperties.check all(
                                 a <- unquote(generator),
                                 b <- unquote(generator)
                               ) do
          # pass as relation doesnt have to be true for all values...
          # TODO : more optimal generator ?? CAREFUL : we want to be sure not to miss anything
          if unquote(relation).(a, b) and unquote(relation).(b, a), do: a === b, else: true
        end
      end
    end
  end

  def descr(generator, relation) do
    rel_str = Utils.string_or_inspect(relation)

    gen_str = Utils.string_or_inspect(generator)

    "#{rel_str} is antisymmetric for #{gen_str}"
  end

  def inspect_descr(value_l, value_r, relation) do
    rel_str = Utils.string_or_inspect(relation)

    value_l_str = Utils.string_or_inspect(value_l)

    value_r_str = Utils.string_or_inspect(value_r)

    "#{rel_str}.(#{value_l_str}, #{value_r_str}) and #{rel_str}.(#{value_r_str}, #{value_l_str}) => #{value_r_str} == #{value_l_str} ? "
  end
end
