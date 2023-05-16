defmodule Relations.CompiledTests do
  @moduledoc false

  alias Relations.Properties

  defmodule UndefinedError do
    @moduledoc ~S"""
    Warning if reltest is used, but the module is missing the relation.
    """

    @type t :: %Relations.CompiledTests.UndefinedError{
            module: module(),
            message: String.t()
          }

    defexception message: "Relation not defined for type", module: nil

    @doc ~S"""
    Convenience constructor

    ## Examples

        iex> Relations.CompiledTests.CompiledTests.UndefinedError.new(MyModule)
        %Relations.UndefinedError{
          module: MyModule,
          message: ~S"
          MyModule has not defined any relation, but they are required.

          See `Relations.CompiledTests.defrel/1` for more
          "
        }

    """
    @spec new(module()) :: t()
    def new(module) do
      %Relations.CompiledTests.UndefinedError{
        module: module,
        message: """
        #{module} has not defined any relation, but at least one is required.

        See `Relations.CompiledTests.defrel/1` for more details.
        """
      }
    end
  end

  @doc ~S"""
  Ensure that the class has defined the relation
  """
  @spec ensure!() :: no_return()
  defmacro ensure!() do
    module = __CALLER__.module
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

  defmacro defrel(definition, properties \\ [inspect: false], do: body) do
    module = __CALLER__.module

    gen_module = Module.concat([module, Generator])

    # IO.inspect("In macro defrel for #{module}")

    # definition |> IO.inspect()

    reldef =
      quote do
        def unquote(definition) do
          unquote(body)
        end
      end

    {rel, _ctx, _contents} = definition

    # default description using relation name and generator module
    descr = "#{rel}"

    properties =
      Keyword.update(properties, :descr, descr, fn d ->
        if is_nil(d), do: descr, else: d
      end)

    # Properties of the relation 
    test_module =
      quote do
        # TODO : multiple relations ??
        defmodule Test do
          require Relations.Properties

          # @generator &unquote(module).all/0
          @relation &(unquote(module).unquote(rel) / 2)

          def relation, do: @relation

          use ExUnit.Case
          use ExUnitProperties

          Relations.Properties.describe(
            unquote(gen_module).all(),
            # &(unquote(module).unquote(rel) / 2),
            @relation,
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
        rel_proptest_module = Module.concat([module, Test])

        # gathering relation property tests
        for {reltest_name, one} <-
              rel_proptest_module.__info__(:functions)
              |> Enum.filter(fn {n, a} -> not String.starts_with?(Atom.to_string(n), "__") end)
              |> Enum.filter(fn {n, a} -> n != :relation end) do
          t =
            ExUnit.Case.register_test(
              __MODULE__,
              env_file,
              env_line,
              Properties.Utils.string_or_inspect(rel_proptest_module),
              reltest_name,
              []
            )

          def unquote(t)(_) do
            # calling reltest_name test from relationtest module, with module and relation in context

            apply(unquote(rel_proptest_module), unquote(reltest_name), [
              %{module: unquote(module)}
            ])
          end
        end
      end

    [require, tests]
  end
end
