defmodule Relations.Generator do
  defmacro __using__(_opts) do
    quote do
      import Relations.Generator, only: [defgen: 1]
    end
  end

  defmacro defgen(fields) do
    module = __CALLER__.module

    clauses_and_body = clauses_and_body(module, fields)
    # [do: body] = List.last(clauses_and_body)

    # IO.inspect("In macro defgen for #{module}")

    # We need a module here to make the function usable in the outerscope
    # during macro expansion.
    quote do
      defmodule All do
        require ExUnitProperties
        import StreamData

        def gen() do
          ExUnitProperties.gen(all(unquote_splicing(clauses_and_body)))
        end
      end

      defdelegate gen(), to: All, as: :gen
    end

    # unquote(args) |> Enum.into(%unquote(caller){})
  end

  defmodule UndefinedError do
    @moduledoc ~S"""
    Warning if reltest is used, but the module is missing the relation.
    """

    @type t :: %Relations.Generator.UndefinedError{
            module: module(),
            message: String.t()
          }

    defexception message: "Generator not defined for Relation", module: nil

    @doc ~S"""
    Convenience constructor

    ## Examples

        iex> Relations.UndefinedError.new(MyModule)
        %Relations.UndefinedError{
          module: MyModule,
          message: ~S"
          MyModule has not defined any generator, but they are required.

          See `Relations.defgen/1` for more
          "
        }

    """
    @spec new(module()) :: t()
    def new(module) do
      %Relations.Generator.UndefinedError{
        module: module,
        message: """
        #{module} has not defined any generator, but at least one is required.

        See `Relations.defgen/1` for more details.
        """
      }
    end
  end

  @spec ensure!() :: no_return()
  defmacro ensure!() do
    module = __CALLER__.module |> IO.inspect()
    gen_mod = Module.concat([module, All])

    quote do
      case Code.ensure_loaded(unquote(gen_mod)) do
        {:module, _prop_submodule} ->
          nil

        {:error, :nofile} ->
          raise UndefinedError.new(unquote(gen_mod))
      end
    end
  end

  @spec clauses_and_body(atom(), Keyword.t()) :: {Keyword.t(), List.t()}
  def clauses_and_body(module, fields) do
    args = Macro.generate_unique_arguments(length(fields), __MODULE__)

    {args, clauses} =
      fields
      |> Enum.zip(args)
      |> Enum.map(fn {{k, g}, a} ->
        {{k, a},
         quote do
           unquote(a) <- unquote(g)
         end}
      end)
      |> Enum.unzip()

    # quoting body to prevent too early resolution attempt.
    # Should be unquoted on use
    clauses ++ [[do: quote(do: Kernel.struct(unquote(module), unquote(args)))]]
  end
end
