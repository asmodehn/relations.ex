defmodule ExUnitContinuous.ExUnitServer do
  @moduledoc ~s"""
    This modules adds an interface to ExUnit.Server, to manipulate its state
    when there is no expected interface for it.

    BEWARE: This should be kept to a minimum.
    Before any modification, it is necessary to understand how ExUnit.Server works.
  """

  require Logger

  @doc ~s"""
    Get the pid of ExUnit.Server Process
  """
  @spec pid() :: PID.t()
  def pid() do
    Process.whereis(ExUnit.Server)
  end

  @doc ~s"""
    Little hack to get the list of sync modules in ExUnit.Server
  """
  @spec _sync_modules() :: [atom()]
  def _sync_modules() do
    :sys.get_state(pid())[:sync_modules]
  end

  @doc ~s"""
    Little hack to update the list of sync modules in ExUnit.Server
  """
  @spec _sync_modules(([atom()] -> [atom()])) :: [atom()]
  def _sync_modules(fun) do
    :sys.replace_state(pid(), fn
      %{sync_modules: sync_mods} = state ->
        %{state | sync_modules: fun.(sync_mods)}
    end)

    _sync_modules()
  end

  @doc ~s"""
    Little hack to get the list of async modules in ExUnit.Server
  """
  @spec _async_modules() :: [atom()]
  def _async_modules() do
    :sys.get_state(pid())[:async_modules]
  end

  @doc ~s"""
    Little hack to update the list of async modules in ExUnit.Server
  """
  @spec _async_modules(([atom()] -> [atom()])) :: [atom()]
  def _async_modules(fun) do
    :sys.replace_state(pid(), fn
      %{async_modules: async_mods} = state ->
        %{state | async_modules: fun.(async_mods)}
    end)

    _async_modules()
  end

  @doc ~s"""
    Little hack to get the loaded state from ExUnit.Server
  """
  @spec _loaded() :: integer() | :done
  def _loaded() do
    :sys.get_state(pid())[:loaded]
  end

  @doc ~s"""
    Attempt at adding async module without triggering exception from ExUnit.Server
  """
  @spec add_async_module(atom()) :: :ok | :already_running
  def add_async_module(module) do
    try do
      ExUnit.Server.add_async_module(module)
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        reraise e, __STACKTRACE__
    end
  end

  @doc ~s"""
    Drop all sync modules from ExUnit.Server
  """
  @spec drop_sync_modules() :: [atom()]
  def drop_sync_modules() do
    # highjack registered ex_unit tests to remove the non-async ones
    # before starting the test suite.
    sync_mods = _sync_modules()
    _sync_modules(fn _ -> [] end)

    if sync_mods do
      IO.warn("Ignored sync test modules: #{inspect(sync_mods)}.")
    end

    sync_mods
  end
end
