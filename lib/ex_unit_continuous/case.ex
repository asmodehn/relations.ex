defmodule ExUnitContinuous.Case do

  # TODO : maybe useless/harmful if we dont want to change anything in ExUnit.Case behaviour.


  @doc ~s"""
      use this macro in a test module that should be run by `ExUnitContinuous`.
      To also be run via ExUnit, `register_test()` needs to be called for each test.
  """
  defmacro __using__(_opts \\ []) do
    # to use in a test meant to be run with ExUnitContinuous
    quote do
      # We do not want to rely on ExUnit to register the tests.
      # Instead we register our own after_compile callback
      # that will register only the async tests.
      use ExUnit.Case, register: false, async: true

      # dynamically replacing after_compile with ours
      # to prevent automatic trigger of sync tests via ExUnit
      Module.put_attribute(__MODULE__, :after_compile, ExUnitContinuous.Case)

    end
  end

  @doc false
  def __after_compile__(%{module: module}, _) do

    cond do
      Process.whereis(ExUnit.Server) == nil ->
        unless Code.can_await_module_compilation?() do
          raise "cannot use ExUnitContinuous.Case without starting the ExUnit application, " <>
                  "please make sure the :ex_unit app is started"
        end

      Module.get_attribute(module, :ex_unit_async, nil) |> IO.inspect() ->
        ExUnit.Server.add_async_module(module)

      true ->
        # Note : we do not want to start sync module tests
        # as they may have side effects
        # ExUnit.Server.add_sync_module(module)
        raise ExUnitContinuous.SyncTestException.new(module)
    end
  end



end
