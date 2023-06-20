defmodule ExUnitContinuous.Case do
  defmacro __using__(opts) do
    {async, _opts} = Keyword.pop(opts, :async, true)

    # to use in a test meant to be run with ExUnitContinuous
    quote do
      use ExUnit.Case, register: false, async: unquote(async)
      # We dont want to register the test in the ExUnit suite automatically.
      #    ExUnitContinuous will load it dynamically before running instead.
    end
  end
end
