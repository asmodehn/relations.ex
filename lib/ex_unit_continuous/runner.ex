defmodule ExUnitContinuous.Runner do
  #  # compile a string (filepath) to a module
  #  def ensure_modules(to_run) do
  #    to_run
  #    |> Enum.flat_map(fn
  #      f when is_binary(f) -> Code.compile_file(f)
  #      m when is_atom(m) -> [m]
  #    end)
  #    # TODO : how to deal with errors in compilation ??
  #    |> Enum.map(fn
  #      {m, _} -> m
  #      m -> m
  #    end)
  #  end

  defmacro run_in_test(module) when is_atom(module) do
    caller = __CALLER__

    require =
      if is_atom(module) do
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
        # gathering relation property tests
        for {test_name, one} <-
              module.__info__(:functions)
              |> Enum.filter(fn
                {n, a} -> not String.starts_with?(Atom.to_string(n), "__")
              end) do
          t =
            ExUnit.Case.register_test(
              __MODULE__,
              env_file,
              env_line,
              ExUnitContinuous.Utils.string_or_inspect(module),
              test_name,
              []
            )

          def unquote(t)(_) do
            # calling test_name test from module
            apply(unquote(module), unquote(test_name), [%{}])
          end
        end
      end

    [require, tests]
  end

  defmacro run_in_test({:__aliases__, _, _} = quoted_atom_module) do
    caller = __CALLER__
    module = Macro.expand(quoted_atom_module, caller)

    quote do
      run_in_test(unquote(module))
    end
  end

  defmacro run_in_test(test_file) when is_binary(test_file) do
    for compiled <- Code.compile_file(test_file) do
      #        IO.inspect(compiled)
      case compiled do
        {module_atom, _} ->
          quote do
            run_in_test(unquote(module_atom))
          end

        {_module_atom, _ctx, _} ->
          raise %RuntimeError{}

        other ->
          IO.inspect(other)
          raise %RuntimeError{}
      end
    end
  end

  defmacro run_in_test(test_modules) when is_list(test_modules) do
    for m <- test_modules do
      # to resolve any quoted module in test_modules
      expanded = Macro.expand(m, __CALLER__)

      quote do
        run_in_test(unquote(expanded))
      end
    end
  end

  #  defmacro run_in_test(anything) do
  #    IO.inspect(anything)
  #    quote do
  #
  #    end
  #  end

  defmacro run(files_or_modules) do
    module = __CALLER__.module

    # If running in a module with ExUnit.Case
    functions =
      module.__info__(:functions)
      |> IO.inspect()

    # TODO : look for __ex_unit__ function... defined on __before_compile__ for tests

    # we use the macro to expand to test on interpretation.
    if "__ex_unit__" in functions do
      for mf <- files_or_modules do
        quote do
          run_in_test(unquote(mf))
        end
      end
    else
      # Otherwise we can run ExUnit dynamically, as a test suite is not currently running.
      quote do
        ExUnit.run(files_or_modules)
      end
    end
  end
end
