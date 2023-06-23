defmodule ExUnitContinuous.Case do
  @moduledoc ~s"""
    This module handles hijacking ExUnit.Case behaviour,
    to make it suitable for running in various environments, such as:
    - make sure the tests are declared async (should be side-effects free)
    - prevent sync tests from being run automatically.
  """

  # TODO : maybe useless/harmful if we dont want to change anything
  # in ExUnit.Case behaviour.

  @doc ~s"""
    Use this macro in a test module that should be run by `ExUnitContinuous`.
    It declares the module as an async test, and registers only async tests on after compile
  """
  defmacro __using__(_opts \\ []) do
    source_file = __CALLER__.file
    module = __CALLER__.module

    Module.register_attribute(module, :source_path, accumulate: false, persist: true)

    # to use in a test meant to be run with ExUnitContinuous
    quote do
      # We do not want to rely on ExUnit to register the tests.
      # Instead we register our own after_compile callback
      # that will register only the async tests.
      use ExUnit.Case, register: false, async: true

      # registering the file path for later updates...
      @source_path unquote(source_file)

      # dynamically replacing after_compile with ours
      # to prevent automatic trigger of sync tests via ExUnit
      @after_compile ExUnitContinuous.Case
    end

    # TODO : this can likely be improved, by letting the usual `use ExUnit...`
    # declaration in the test module, but only highjack the aftercompile...
  end

  @doc false
  def __after_compile__(%{module: module}, _) do
    cond do
      Process.whereis(ExUnit.Server) == nil ->
        unless Code.can_await_module_compilation?() do
          raise "cannot use ExUnitContinuous.Case without starting the ExUnit application, " <>
                  "please make sure the :ex_unit app is started"
        end

      Module.get_attribute(module, :ex_unit_async, nil) ->
        ExUnit.Server.add_async_module(module)

        # Note:  we completely skip the sync modules.
    end
  end
end
