defmodule ExUnitContinuous.RunnerAsyncTest do
  use ExUnit.Case, async: true

  alias ExUnitContinuous.ExUnitServer

  # TODO: some useful tests without side-effect ?

end

defmodule ExUnitContinuous.RunnerTest do
  use ExUnit.Case

  alias ExUnitContinuous.ExUnitServer

  test "add_async_modules/1 returns `:sync_module` for non-async modules" do
    assert ExUnitContinuous.Runner.add_async_module(__MODULE__) == :sync_module
  end

  test "add_async_modules/1 accepts async modules, even while running" do
    on_exit(fn ->
      ExUnitServer._async_modules(fn sm -> sm |> List.delete(__MODULE__) end)
    end)
    assert ExUnitContinuous.Runner.add_async_module(ExUnitContinuous.RunnerAsyncTest) == :ok
  end

#  test "run returns :wait_for_it when ExUnit is already running" do
#    assert_raise  ExUnitContinuous.AlreadyRunningException, fn ->
#      ExUnitContinuous.Runner.run([__MODULE__])
#    end
#  end

end