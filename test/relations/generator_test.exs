defmodule Relations.GeneratorTest do
  use ExUnit.Case
  doctest Relations.Generator

  alias Relations.Generator

  require ExUnitProperties
  require StreamData

  describe "clauses_and_body/1" do
    setup do
      defmodule FakeModC do
        defstruct f1: nil,
                  f2: nil
      end

      # pass the name of the module to all tests
      %{module: FakeModC.__info__(:module)}
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

  describe "defstream/2" do
    setup do
      defmodule FakeModS do
        defstruct f1: nil,
                  f2: nil

        use Relations.Generator

        defstream(all(f1: member_of([:f1_code]), f2: member_of([:f2_code])))
      end

      # pass the name of the module to all tests
      %{module: FakeModS.__info__(:module)}
    end

    test "builds a definition providing a stream of struct for the module with these fields", %{
      module: module
    } do
      # Note Here we need to rely on Kernel struct because module is defined dynamically.
      assert module.all() |> Enum.take(2) == [
               Kernel.struct(module, f1: :f1_code, f2: :f2_code),
               Kernel.struct(module, f1: :f1_code, f2: :f2_code)
             ]
    end
  end

  describe "quoted_gen_body_delegates/2" do
    setup do
      defmodule FakeModG do
        defstruct f1: nil,
                  f2: nil
      end

      # pass the name of the module to all tests
      %{module: FakeModG.__info__(:module)}
    end

    test "returns expected quoted expression for a def" do
      {qdlg, qdef} =
        Generator.quoted_gen_body_delegates(
          quote do
            def myfun(), do: 42
          end,
          caller: %{module: DynTestModule},
          nested: Nested
        )

      dy_test_module =
        quote do
          defmodule DynTestModule do
            defmodule Nested do
              unquote(qdef)
            end

            unquote(qdlg)
          end

          # assertion in quote for dynamic test
          {
            DynTestModule.Nested.myfun(),
            # also checking that the delegate works as expected
            DynTestModule.myfun()
          }
        end

      {{42, 42}, []} = Code.eval_quoted(dy_test_module)
    end
  end

  describe "generators/1 with one definition" do
    setup do
      defmodule OneGenExample do
        defstruct int: 0,
                  mod: 8

        use Relations.Generator

        generators do
          def myname do
            ExUnitProperties.gen all(
                                   i <- integer(),
                                   m <- integer(1..8)
                                 ) do
              %OneGenExample{int: i, mod: m}
            end
          end
        end
      end

      # pass the name of the module to all tests
      %{module: OneGenExample.__info__(:module)}
    end

    test "produces a named function with arity 0 in module, usable in property checks", %{
      module: module
    } do
      ExUnitProperties.check all(v <- apply(module, :myname, [])) do
        # Enable inspect if you want to see this working.
        # v |> IO.inspect()
        %^module{int: i, mod: m} = v
        assert is_integer(i)
        assert is_integer(m) and m > 0 and m <= 8
      end
    end
  end

  describe "generators/1 with one defstream" do
    setup do
      defmodule DefStreamExample do
        defstruct int: 0,
                  mod: 8

        use Relations.Generator

        generators do
          defstream(
            myname(
              int: integer(),
              mod: integer(1..8)
            )
          )
        end
      end

      # pass the name of the module to all tests
      %{module: DefStreamExample.__info__(:module)}
    end

    test "produces one named functions with arity 0 in module, usable in property checks", %{
      module: module
    } do
      ExUnitProperties.check all(v <- apply(module, :myname, [])) do
        # Enable inspect if you want to see this working.
        # v |> IO.inspect()
        %^module{int: i, mod: m} = v
        assert is_integer(i)
        assert is_integer(m) and m > 0 and m <= 8
      end
    end
  end

  describe "generators/1 with various definition" do
    setup do
      defmodule MultiDefExample do
        defstruct int: 0,
                  mod: 8

        use Relations.Generator

        generators do
          defstream(
            myname(
              int: integer(),
              mod: integer(1..8)
            )
          )

          def anothername() do
            ExUnitProperties.gen all(
                                   i <- integer(),
                                   m <- integer(1..7)
                                 ) do
              %MultiDefExample{int: i, mod: m}
            end
          end
        end
      end

      # pass the name of the module to all tests
      %{module: MultiDefExample.__info__(:module)}
    end

    test "produces two named functions with arity 0 in module, usable in property checks", %{
      module: module
    } do
      ExUnitProperties.check all(v <- apply(module, :myname, [])) do
        # Enable inspect if you want to see this working.
        # v |> IO.inspect()
        %^module{int: i, mod: m} = v
        assert is_integer(i)
        assert is_integer(m) and m > 0 and m <= 8
      end

      ExUnitProperties.check all(v <- apply(module, :anothername, [])) do
        # Enable inspect if you want to see this working.
        # v |> IO.inspect()
        %^module{int: i, mod: m} = v
        assert is_integer(i)
        assert is_integer(m) and m > 0 and m <= 7
      end
    end
  end
end
