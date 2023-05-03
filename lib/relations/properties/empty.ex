defmodule Relations.Properties.Empty do
  alias Relations.Properties.Utils

  def quoted_property(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr, nil)

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
        property Relations.Properties.Empty.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  def quoted_check(generator, relation, inspect: inspect) do
    if inspect do
      quote do
        check all(
                l <- unquote(generator),
                r <- unquote(generator)
              ) do
          IO.write(Relations.Properties.Empty.inspect_descr(l, r, unquote(relation)))
          res = unquote(relation).(l, r)
          IO.inspect(res)
          assert res == false
        end
      end
    else
      quote do
        check all(
                l <- unquote(generator),
                r <- unquote(generator)
              ) do
          assert unquote(relation).(l, r) == false
        end
      end
    end
  end

  def descr(generator, relation) do
    rel_str = Utils.string_or_inspect(relation)

    gen_str = Utils.string_or_inspect(generator)

    "#{rel_str} is empty for #{gen_str}"
  end

  def inspect_descr(value_l, value_r, relation) do
    rel_str = Utils.string_or_inspect(relation)

    value_l_str = Utils.string_or_inspect(value_l)

    value_r_str = Utils.string_or_inspect(value_r)

    "#{rel_str}.(#{value_l_str}, #{value_r_str}) => false ? "
  end
end
