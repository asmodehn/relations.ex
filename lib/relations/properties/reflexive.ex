defmodule Relations.Properties.Reflexive do
  alias Relations.Properties.Utils

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
