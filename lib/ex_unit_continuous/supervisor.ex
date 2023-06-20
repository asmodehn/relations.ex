defmodule ExUnitContinuous.Supervisor do
  @ex_unit_server_spec %{
    # id intentionnally conflicts with ExUnit's ids, to make sure there is no overlap
    id: ExUnit.Server,
    start: {ExUnit.Server, :start_link, [nil]},
    restart: :transient
  }

  @ex_unit_capture_server_spec %{
    # id intentionnally conflicts with ExUnit's ids, to make sure there is no overlap
    id: ExUnit.CaptureServer,
    start: {ExUnit.CaptureServer, :start_link, [nil]},
    restart: :transient
  }

  # Automatically defines child_spec/1
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # See https://github.com/elixir-lang/elixir/blob/v1.15.0-rc.1/lib/ex_unit/lib/ex_unit.ex#L1
    children = [
      # These are duplicate of ExUnit, so we change the id to prevent conflict on "mix test" runs
      #      ExUnit.Server,
      #      %{ id: ExUnitContinuous.Server,
      #        start: {ExUnit.Server, :start_link, [nil]},
      #        restart: :transient
      #      },
      #      ExUnit.CaptureServer,
      #      %{ id: ExUnitContinuous.CaptureServer,
      #        start: {ExUnit.CaptureServer, :start_link, [nil]},
      #        restart: :transient
      #      }
      #      ExUnit.OnExitHandler
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  #  @doc """
  #      Second level start to dynamically start ExUnit components,
  #      on an already running application.
  #  """
  #  def start() do
  #    with {:ok, _srv} <- Supervisor.start_child(__MODULE__, @ex_unit_server_spec),
  #          {:ok, _capt_srv} <- Supervisor.start_child(__MODULE__, @ex_unit_capture_server_spec) do
  #  # TODO : ExitHandler to run tests, like usual cli usecase ?? or not ??
  #
  #    # TODO: handle errors in case ExUnit Servers are already running
  #    # WAIT for it, dont reuse or force restart existing Servers.
  #    # => Running ExUnit (manually on a running app for instance)
  #    #    will effectively "pause" ExUnitContinuous app
  #      end
  #  end
  #
  #
  #  def stop() do
  #    with {:ok} <- Supervisor.stop_child(__MODULE__, )
  #
  #
  #  end
end
