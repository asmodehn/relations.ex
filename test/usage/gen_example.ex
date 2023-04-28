defmodule GenExample do
  defstruct int: 0,
            mod: 8

  use Relations.Generator

  defgen(
    int: integer(),
    mod: integer() |> filter(fn x -> x <= 8 end)
  )
end
