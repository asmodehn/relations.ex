defmodule ExUnitContinuous.Updater do
  @moduledoc """
     This module manages compilation of source to module,
    and more trickery (to come) to deploy updates to test code.
  """

  alias ExUnitContinuous.ExUnitServer

  @doc ~s"""
    Compilation as a macro to be run potentially before other macros...
  """
  def compile!(filepath, opts \\ [drop_sync: true]) do
    drop_sync = Keyword.get(opts, :drop_sync, true)

    compiled =
      for compiled <- Code.compile_file(filepath) do
        case compiled do
          {module_atom, _} ->
            module_atom

          # TODO : better handle these
          {_module_atom, _ctx, _} ->
            raise %RuntimeError{}

          _other ->
#            IO.inspect(other)
            raise %RuntimeError{}
        end
      end

    if drop_sync do

      sync_mods = ExUnitServer.drop_sync_modules()

      compiled |> Enum.filter(fn m -> m not in sync_mods end)
    else
      compiled
    end
  end


  @doc ~s"""
    Recompile the source_file and loads it.
    It is currently forcing it, and will trigger a warning,
    as we currently don't have a way to check if the loaded module is up_to_date
    with the source file.

    This needs to be improved...
  """
  def ensure_updated(_module, source_file, opts \\ [drop_sync: true]) do
    compile!(source_file, opts)
  end
  # TODO : figure out how to link module with source file...
end
