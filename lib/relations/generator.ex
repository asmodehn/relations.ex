defmodule Relations.Generator do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Relations.Generator, only: [defstream: 1, generators: 1]
    end
  end

  defmacro defstream({name, _ctx, [fields]}) when is_list(fields) do
    module = __CALLER__.module

    clauses_and_body = clauses_and_body(module, fields)

    req =
      quote do
        require ExUnitProperties
        import StreamData
      end

    dfstr =
      quote do
        def unquote(name)() do
          ExUnitProperties.gen(all(unquote_splicing(clauses_and_body)))
        end
      end

    [req, dfstr]
  end

  defp quoted_def_delegate(name, to: module) do
    quote do
      defdelegate unquote(name)(), to: unquote(module), as: unquote(name)
    end
  end

  defp name_def({:def, _ctx, [{name, _, args} | _do_body]} = gen_def, caller: _caller)
       when args in [nil, []] do
    {name, gen_def}
  end

  defp name_def({:defstream, _ctx, [{name, _, [_arg_list]}]} = stream_def, caller: caller) do
    {name, Macro.expand(stream_def, caller)}
  end

  def quoted_gen_body_delegates(gen_def, caller: caller, nested: nested)
      when elem(gen_def, 0) in [:def, :defstream] do
    # extract name from gen_def
    {name, expanded_def} = name_def(gen_def, caller: caller)
    # return delegate and potentially expanded gen_def
    {[quoted_def_delegate(name, to: Module.concat(caller.module, nested))], [expanded_def]}
  end

  def quoted_gen_body_delegates({:__block__, _ctx, gen_defs}, caller: caller, nested: nested) do
    # we browse the defs, optionally expanding a defstream macro,
    # the resulting body is the accumulator, after reducing.
    {delegates, body} =
      Enum.flat_map_reduce(gen_defs, [], fn df, acc ->
        {delegate, expanded_def} = quoted_gen_body_delegates(df, caller: caller, nested: nested)
        {delegate, acc ++ expanded_def}
      end)

    {delegates, body}
  end

  defmacro generators(do: body) do
    module = __CALLER__.module

    {delegates, gen_body} = quoted_gen_body_delegates(body, caller: __CALLER__, nested: Generator)

    quote do
      defmodule Generator do
        @moduledoc false

        require ExUnitProperties
        import StreamData

        alias unquote(module)

        unquote_splicing(gen_body)
      end

      unquote_splicing(delegates)
    end
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
    module = __CALLER__.module
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
