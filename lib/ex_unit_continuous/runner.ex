defmodule ExUnitContinuous.Runner do

  alias ExUnitContinuous.AlreadyRunningException


  @spec add_async_module(atom()) :: :ok | :already_running | :sync_module
  def add_async_module(module) do
    # Ensure this is an async test
    # => no side-effect, can run along side other tests and the app
    unless module.__info__(:attributes)
      |> Keyword.get(:ex_unit_async, [false])
      |> Enum.all?() do
      :sync_module
    else
      case ExUnit.Server.add_async_module(module) do
        :already_running -> :already_running
        :ok -> :ok
      end
    end
  end


  defp persist_defaults(config) do
    config
    |> Keyword.take([:max_cases, :seed, :trace])
    |> ExUnit.configure()

    config
  end


  def run(additional_modules \\ []) when is_list(additional_modules)  do
    for module <- additional_modules do
      case add_async_module(module) do
        :sync_module -> :sync_module  # just ignore this case
        :already_running -> raise AlreadyRunningException.new(module)
        :ok -> :ok
      end
    end

    config = ExUnit.configuration()

    unless config[:continuous_autorun] do
      # Duplicated from ExUnit code
      time = ExUnit.Server.modules_loaded(additional_modules != [])
      options = persist_defaults(config)
      ExUnit.Runner.run(options, time)
    end
  end


end
