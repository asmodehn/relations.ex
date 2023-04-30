defmodule Relations.GeneratorTest do
  use ExUnit.Case
  doctest Relations.Generator

  alias Relations.Generator

  require ExUnitProperties
  require StreamData

  describe "clauses_and_body/1" do
    setup do
      defmodule FakeMod do
        defstruct f1: nil,
                  f2: nil
      end

      # pass the name of the module to all tests
      %{module: FakeMod.__info__(:module)}
    end

    test "accepts a keyword list of fields and returns clauses and body, usable with with/1 ", %{
      module: module
    } do
      clauses_and_body = Generator.clauses_and_body(module, f1: :f1_code, f2: :f2_code)

      expr =
        quote do
          with unquote_splicing(clauses_and_body)
        end

      # pattern match works
      {%^module{f1: :f1_code, f2: :f2_code} = struct, []} = Code.eval_quoted(expr)

      # struct is usable as expected
      assert struct.f1 == :f1_code
      assert struct.f2 == :f2_code
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
          mod: integer(1..8)
        )
      end

      # pass the name of the module to all tests
      %{module: DynExample.__info__(:module)}
    end

    test "produces a gen/0 function in module, usable in property checks", %{module: module} do
      check all(v <- apply(module, :gen, [])) do
        # Enable inspect if you want to see this working.
        # v |> IO.inspect()
        %^module{int: i, mod: m} = v
        assert is_integer(i)
        assert is_integer(m) and m > 0 and m <= 8
      end
    end
  end
end
