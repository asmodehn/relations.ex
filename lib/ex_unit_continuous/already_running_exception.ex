defmodule ExUnitContinuous.AlreadyRunningException do
    @moduledoc ~S"""
    Error if a test module is not marked async.
    """

    @type t :: %__MODULE__{
            module: atom(),
            message: String.t()
          }

    defexception message: "Test Suite Already running", module: nil

    @doc ~S"""
    Convenience constructor
    """
    @spec new(atom()) :: t()
    def new(module) do
      %__MODULE__{
        module: module,
        message: """
          #{module} cannot be added while test suite is running."
        """
      }
    end

    # TODO : When using a schedule this can be fixed / avoided
  end