defmodule Relations.Properties.Identity do
  alias Relations.Properties.Utils

  def quoted_check(generator, relation, inspect: inspect) do
    if inspect do
      quote do
        # TODO : other generator
        check all(
                i <- unquote(generator),
                o <- unquote(generator) |> StreamData.filter(fn x -> x != i end)
              ) do
          IO.write(inspect_descr(i, o, unquote(relation)))
          res = unquote(relation).(i, i) and not unquote(relation).(i, o)
          IO.inspect(res)
          assert res
        end
      end
    else
      quote do
        # TODO : other generator
        check all(
                i <- unquote(generator),
                o <- unquote(generator) |> StreamData.filter(fn x -> x != i end)
              ) do
          assert unquote(relation).(i, i) and not unquote(relation).(i, o)
        end
      end
    end
  end

  def descr(generator, relation) do
    rel_str = Utils.string_or_inspect(relation)

    gen_str = Utils.string_or_inspect(generator)

    "#{rel_str} is identity for #{gen_str}"
  end

  def inspect_descr(value_i, value_o, relation) do
    rel_str = Utils.string_or_inspect(relation)

    value_i_str = Utils.string_or_inspect(value_i)
    value_o_str = Utils.string_or_inspect(value_o)

    "#{rel_str}.(#{value_i_str}, #{value_i_str}) and not #{rel_str}.(#{value_i_str}, #{value_o_str}) ? "
  end
end
