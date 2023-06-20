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

  #  @doc """
  #    Run a usual ExUnit.Case test module, if it is already compiled.
  #
  #    If it is not compiled, but the source is accessible, the path can be passed in instead.
  #    This is useful for scripts.
  #
  #  ## Examples
  #
  #      iex> ExUnitContinuous.run(["test/usage/test/example_test.exs"])
  #      %{excluded: 0, failures: 0, skipped: 0, total: 4}
  #
  #      iex> ExUnitContinuous.run([ExampleTest])
  #      %{excluded: 0, failures: 0, skipped: 0, total: 4}
  #
  #  """

  defmacro run(m) do
    quote do
      require ExUnitContinuous.Runner
      ExUnitContinuous.Runner.run(unquote(m))
    end
  end
end
