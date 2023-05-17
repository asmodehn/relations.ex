defmodule Relations.Properties.Reflexive do
  @moduledoc false

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
        property Relations.Properties.Reflexive.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  def quoted_check(generator, relation, inspect: inspect) do
    if inspect do
      quote do
        check all(r <- unquote(generator)) do
          IO.write(Relations.Properties.Reflexive.inspect_descr(r, unquote(relation)))
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
  end

  def descr(generator, relation) do
    rel_str = Utils.string_or_inspect(relation)

    gen_str = Utils.string_or_inspect(generator)

    "#{rel_str} is reflexive for #{gen_str}"
  end

  def inspect_descr(value, relation) do
    rel_str = Utils.string_or_inspect(relation)

    value_str = Utils.string_or_inspect(value)

    "#{rel_str}.(#{value_str}, #{value_str}) ? "
  end
end
