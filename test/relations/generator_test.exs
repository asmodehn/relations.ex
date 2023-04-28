defmodule Relations.GeneratorTest do
  use ExUnit.Case
  doctest Relations.Generator

  alias Relations.Generator

  require ExUnitProperties
  require StreamData

  describe "clauses_and_body/1" do
    test "accepts a keyword list of fields and returns clauses and body, usable with with/1 " do
      clauses_and_body = Generator.clauses_and_body(f1: :f1_code, f2: :f2_code)

      expr =
        quote do
          with unquote_splicing(clauses_and_body)
        end

      assert Code.eval_quoted(expr) == {[f1: :f1_code, f2: :f2_code], []}
    end
  end

  describe "defgen/1" do
    use ExUnitProperties

    setup do
      defmodule DynExample do
        defstruct int: 0,
                  mod: 8

        use Relations.Generator

        defgen(
          int: integer(),
          mod: integer() |> filter(fn x -> x <= 8 end)
        )
      end

      # pass the name of the module to all tests
      %{module: DynExample.__info__(:module)}
    end

    test "produces a gen/0 function in the module, usable in property checks", %{module: module} do
      check all(v <- apply(module, :gen, [])) do
        # Enable inspect if you want to see this working.
        # |> IO.inspect()
        [int: i, mod: m] = v
        assert is_integer(i)
        assert is_integer(m) and m <= 8
      end
    end
  end
end
