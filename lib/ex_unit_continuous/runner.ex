defmodule ExUnitContinuous.Runner do
  @moduledoc ~s"""
    This module manages running ExUnit tests
  """

  alias ExUnitContinuous.AlreadyRunningException
  alias ExUnitContinuous.ExUnitServer

  @doc ~s"""
    Adds an async module to ExUnit.Server, to be tested later on.
    returns `:sync_module`, if the module doesn't declare `ExUnit.Case, async: true`
  """
  @spec add_async_module(atom()) :: :ok | :already_running | :sync_module
  def add_async_module(module) do
    # Ensure this is an async test
    # => no side-effect, can run along side other tests and the app
    if module.__info__(:attributes)
       |> Keyword.get(:ex_unit_async, [false])
       |> Enum.all?() do
      ExUnitServer.add_async_module(module)
    else
      :sync_module
    end
  end

  # Duplicated from ExUnit
  defp persist_defaults(config) do
    config
    |> Keyword.take([:max_cases, :seed, :trace])
    |> ExUnit.configure()

    config
  end

  @doc ~s"""
    Adds async modules to be tested to the suite, and, when ExUnit is not in autorun mode,
    runs ExUnit tests.

    If ExUnit is in autorun mode, we let ExUnit run
    as usual on `System.at_exit()` instead.
    This is for instance the case when running `$ mix test`

    CAREFUL: due to ExUnit design, this works only if `ExUnitContinuous.start()`
    has be called at the beginning of the tests instead of `ExUnit.start()`.

    If ExUnit is already running, `AlreadyRunningException` is raised.
  """
  @spec run([atom()]) :: :wait_for_it | ExUnit.RunnerStats.t()
  def run(additional_modules \\ []) when is_list(additional_modules) do
    for module <- additional_modules do
      case add_async_module(module) do
        # just ignore this case
        :sync_module -> :sync_module
        :already_running -> raise AlreadyRunningException.new(module)
        :ok -> :ok
      end
    end

    config = ExUnit.configuration()

    if config[:continuous_autorun] do
      :wait_for_it
    else
      # Duplicated from ExUnit code
      time = ExUnit.Server.modules_loaded(additional_modules != [])
      options = persist_defaults(config)
      ExUnit.Runner.run(options, time)
    end
  end
end
