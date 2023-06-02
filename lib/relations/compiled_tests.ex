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

    # default description using relation name
    descr = "#{rel}"

    properties =
      Keyword.update(properties, :descr, descr, fn d ->
        if is_nil(d), do: descr, else: d
      end)

    # Properties of the relation 
    test_module =
      quote do
        # TODO : multiple relations ??
        defmodule Properties do
          @moduledoc false

          require Relations.Properties

          @relation &(unquote(module).unquote(rel) / 2)

          def relation, do: @relation

          use ExUnit.Case
          use ExUnitProperties

          Relations.Properties.describe(
            @relation,
            unquote(properties)
          )
        end
      end

    [reldef, test_module]
  end
end
