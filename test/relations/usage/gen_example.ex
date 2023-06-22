defmodule GenExample do
  @moduledoc false

  defstruct int: 0,
            mod: 8

  use Relations.Generator

  generators do
    defstream(
      all(
        int: integer(),
        mod: integer(1..8)
      )
    )
  end
end
