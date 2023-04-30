defmodule GenExample do
  defstruct int: 0,
            mod: 8

  use Relations.Generator

  defgen(
    int: integer(),
    mod: integer(1..8)
  )
end
