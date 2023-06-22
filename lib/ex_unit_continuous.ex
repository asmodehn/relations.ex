defmodule ExUnitContinuous do
  @moduledoc """
  Documentation for `ExUnitContinuous`.
  """

  defmacro __using__(_opts) do
    quote do
      require ExUnitContinuous
      import ExUnitContinuous, only: [run: 1]
    end
  end


  @doc ~s"""
      This is used in a test helper, just like ExUnit.start().
    It will setup ExUnit appropriately for a common usage of usual `mix test` commands
    as well as continuous tests in other envs.

  """
  @spec start(Keyword.t()) :: :ok
  def start(exunit_options \\ []) do

    {:ok, _} = Application.ensure_all_started(:ex_unit)

    ExUnit.configure(exunit_options)
    config = ExUnit.configuration()

    # Note: adding scheduler for continuous testing
    # might offer an alternative for this..
    continuous_autorun = not config[:autorun]
    ExUnit.start(continuous_autorun: continuous_autorun)

  end

end
