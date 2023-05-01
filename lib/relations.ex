defmodule Relations do
  @moduledoc """
  Documentation for `Relations`.

  A relation is defined in an Elixir module itself.
  It is a small helper defining property tests for a function(any, any) :: boolean behaving as a relation in the mathematical sense.
  """

  require Relations.Generator
  require Relations.Properties

  defmacro __using__(_opts) do
    quote do
      import Relations.CompiledTests, only: [defrel: 3, reltest: 2]
      # TODO : defeq as specific "helper" shortcut to these
    end
  end
end
