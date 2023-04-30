defmodule Relations do
  @moduledoc """
  Documentation for `Relations`.

  A relation is defined in an Elixir module itself.
  It is a small helper defining property tests for a function(any, any) :: boolean behaving as a relation in the mathematical sense.
  """

  require Relations.Generator
  require Relations.Properties

  defmacro __using__(_opts) do
    quote do
      import Relations, only: [defrel: 3, reltest: 2]
      # TODO : defeq as specific "helper" shortcut to these
    end
  end

  defmodule UndefinedError do
    @moduledoc ~S"""
    Warning if reltest is used, but the module is missing the relation.
    """

    @type t :: %Relations.UndefinedError{
            module: module(),
            message: String.t()
          }

    defexception message: "Relation not defined for type", module: nil

    @doc ~S"""
    Convenience constructor

    ## Examples

        iex> Relations.UndefinedError.new(MyModule)
        %Relations.UndefinedError{
          module: MyModule,
          message: ~S"
          MyModule has not defined any relation, but they are required.

          See `Relations.defrel/1` for more
          "
        }

    """
    @spec new(module()) :: t()
    def new(module) do
      %Relations.UndefinedError{
        module: module,
        message: """
        #{module} has not defined any relation, but at least one is required.

        See `Relations.defrel/1` for more details.
        """
      }
    end
  end

  @doc ~S"""
  Ensure that the class has defined the relation
  """
  @spec ensure!() :: no_return()
  defmacro ensure!() do
    module = __CALLER__.module |> IO.inspect()
    tests_mod = Module.concat([module, RelationTest])

    quote do
      case Code.ensure_loaded(unquote(tests_mod)) do
        {:module, _prop_submodule} ->
          nil

        {:error, :nofile} ->
          raise UndefinedError.new(unquote(tests_mod))
      end
    end
  end

  # TODO: add possible properties for a relation, cf. https://math.libretexts.org/Bookshelves/Combinatorics_and_Discrete_Mathematics/A_Spiral_Workbook_for_Discrete_Mathematics_(Kwong)/07%3A_Relations/7.02%3A_Properties_of_Relations
  # Note : total relation or not depends on the genertor used for the property check.

  defmacro defrel(definition, properties \\ [], do: body) do
    module = __CALLER__.module

    gen_module = Module.concat([module, All]) |> IO.inspect()

    # IO.inspect("In macro defrel for #{module}")

    # definition |> IO.inspect()

    reldef =
      quote do
        def unquote(definition) do
          unquote(body)
        end
      end

    {rel, _ctx, _contents} = definition

    # Properties of the relation 
    test_module =
      quote do
        # TODO : multiple relations ??
        defmodule RelationsTest do
          require Relations.Properties

          # @generator &unquote(module).gen/0
          @relation &(unquote(module).unquote(rel) / 2)

          use ExUnit.Case
          use ExUnitProperties

          Relations.Properties.describe(
            unquote(gen_module).gen(),
            &(unquote(module).unquote(rel) / 2),
            unquote(properties)
          )
        end
      end

    [reldef, test_module]
  end

  # properties as a class attribute for this ?? like tag in describe / test ?? 
  # or as paramters of defrel ??

  defmacro reltest(module, _opts \\ []) do
    caller = __CALLER__

    require =
      if is_atom(Macro.expand(module, caller)) do
        quote do
          require unquote(module)
        end
      end

    tests =
      quote bind_quoted: [
              module: module,
              env_line: caller.line,
              env_file: caller.file
            ] do
        rel_proptests = Module.concat([module, RelationsTest])

        # gathering relation property tests
        for {reltest_name, one} <-
              rel_proptests.__info__(:functions)
              |> Enum.filter(fn {n, a} -> not String.starts_with?(Atom.to_string(n), "__") end) do
          # t = ExUnit.Case.register_test(__MODULE__, env_file, env_line, :reltest, reltest_name, [])

          # def unquote(t)(_) do
          # calling reltest_name test from relationtest module, with module and relation in context

          apply(rel_proptests, reltest_name, [%{module: module}])

          # end             
        end
      end

    [require, tests]
  end
end
