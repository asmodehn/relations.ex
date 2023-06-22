defmodule ExUnitContinuous.Updater do

  @moduledoc """
     This module manages compilation of source to module,
    and more trickery (to come) to deploy updates to test code.
  """

  # A hack to drop already registered sync modules from ExUnit.Server
  # Seems we cannot do better/cleaner if we want to be able to reuse
  # all pre-existing tests, written as usual with ExUnit.
  @doc false
  defp drop_sync_modules(exunit_server_pid, sync_modules) do
    :sys.replace_state(exunit_server_pid, fn
      %{sync_modules: all_sync_mods} = state ->
        %{state | sync_modules: all_sync_mods
        |> Enum.filter(fn m -> m not in sync_modules end)}
    end)
    sync_modules
  end

  defp drop_sync_modules(exunit_server_pid) do
  sync_modules = :sys.get_state(exunit_server_pid)[:sync_modules]
    drop_sync_modules(exunit_server_pid, sync_modules)
  sync_modules
  end

  @doc ~s"""
    Compilation as a macro to be run potentially before other macros...
  """
  def compile!(filepath, opts \\ [drop_sync: true]) do
     drop_sync = Keyword.get(opts, :drop_sync, true)

     compiled = for compiled <- Code.compile_file(filepath) do
       case  compiled do
        {module_atom, _} -> module_atom

        {_module_atom, _ctx, _} ->
          raise %RuntimeError{}

        other ->
          IO.inspect(other)
          raise %RuntimeError{}
      end
    end

    if drop_sync do
      pid = Process.whereis(ExUnit.Server)

      # highjack registered ex_unit tests to remove the non-async ones
      sync_mods = drop_sync_modules(pid)
      if sync_mods do
        IO.warn("Ignored sync test modules: #{inspect sync_mods}.")
      end

      compiled |> Enum.filter(fn m -> m not in sync_mods end)
    else
      compiled
    end
  end

  # TODO : ensure_loaded / ensure_compiled similar interface ??

end