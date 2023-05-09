defmodule Relations.Generator do
  defmacro __using__(_opts) do
    quote do
      import Relations.Generator, only: [defstream: 1, generators: 1]
    end
  end

  # defmacro defgen({name, _ctx, [fields]}) when is_list(fields) do
  #   module = __CALLER__.module

  #   clauses_and_body = clauses_and_body(module, fields)

  #   # TODO : check if Generator module is defined...
  #   # => we need a module-level macro...

  #   # We need a module here to make the function usable in the outerscope
  #   # during macro expansion.
  #   quote do
  #     defmodule Generator do
  #       require ExUnitProperties
  #       import StreamData

  #       def unquote(name)() do
  #         ExUnitProperties.gen(all(unquote_splicing(clauses_and_body)))
  #       end
  #     end

  #     defdelegate unquote(name)(), to: Generator, as: unquote(name)
  #   end

  #   # unquote(args) |> Enum.into(%unquote(caller){})
  # end

  defmacro defstream({name, _ctx, [fields]}) when is_list(fields) do
    module = __CALLER__.module |> IO.inspect()

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

    # unquote(args) |> Enum.into(%unquote(caller){})
  end

  # def quoted_generator_delegate({:def , _, [{name, _, []}, _do_body]}, gen_module) do
  # 	quote do
  #     	defdelegate unquote(name)(), to: unquote(gen_module), as: unquote(name)
  #   end
  # end

  # def quoted_generator(gen_defs, module) when is_list(gen_defs) do

  # end

  # defmacro generators(do: {:__block__, [], gen_defs} ) do
  # 	quote do
  # 		unquote(generators(gen_defs))
  # 	end
  # end

  defmacro generators(do: {:__block__, _ctx, gen_defs}) do
    module = __CALLER__.module

    # |> IO.inspect()
    ([
       quote do
         defmodule Generator do
           @moduledoc false

           require ExUnitProperties
           import StreamData

           alias unquote(module)

           unquote_splicing(gen_defs)
         end
       end
     ] ++
       Enum.map(gen_defs, fn {:def, _ctx, [{name, _, []}, _do_body]} ->
         quote do
           defdelegate unquote(name)(), to: Generator, as: unquote(name)
         end
       end))
    |> IO.inspect()
  end

  defmacro generators(do: {:def, _ctx, [{name, _, args} | _do_body]} = gen_def)
           when args in [nil, []] do
    module = __CALLER__.module

    quote do
      defmodule Generator do
        @moduledoc false

        require ExUnitProperties
        import StreamData

        alias unquote(module)

        unquote(gen_def)
      end

      defdelegate unquote(name)(), to: Generator, as: unquote(name)
    end
  end

  defmacro generators(do: {:defstream, _ctx, [{name, _, [_arg_list]}]} = stream_def) do
    module = __CALLER__.module

    # We need to expand the macro with current environment (not inside the nested generator module)
    expanded_stream_def = Macro.expand(stream_def, __CALLER__)

    quote do
      defmodule Generator do
        @moduledoc false

        require ExUnitProperties
        import StreamData

        alias unquote(module)

        unquote(expanded_stream_def)
      end

      defdelegate unquote(name)(), to: Generator, as: unquote(name)
    end
  end

  # TODO : other cases to make matching errors on generators macro more explicit...

  # defmacro generators(do: what) do
  # 	what |> IO.inspect()
  # end

  # defmacro generators(do: gen_defs) when is_list(gen_defs) do

  # 	delegates = gen_defs |> Enum.map(fn {:def , _, [{name, _, []}, _do_body]} -> quote do
  #     	defdelegate unquote(name)(), to: Generator, as: unquote(name)
  #     end
  #   end)

  #   module = __CALLER__.module

  #     delegates |> IO.inspect()

  #   quote do
  #     defmodule Generator do
  #       @moduledoc false

  #       require ExUnitProperties
  #       import StreamData

  #       alias unquote(module)

  #       unquote(gen_defs)
  #     end

  #     unquote(delegates)

  #   end
  # end

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
