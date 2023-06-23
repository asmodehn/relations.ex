defmodule ExUnitContinuous.ExUnitServerASyncTest do
  use ExUnit.Case, async: true

  alias ExUnitContinuous.ExUnitServer

  test "pid/0 discovers the pid of ExUnit.Server" do
    assert ExUnitServer.pid() == Process.whereis(ExUnit.Server)
  end

  test "_sync_modules/0 allows to retrieve the list of sync_modules on the server" do
    assert is_list(ExUnitServer._sync_modules())
    # This contains all other sync test that havent run just yet
  end

  test "_async_modules/0 allows to retrieve the list of async_modules on the server" do
    # empty as async tests are taken for a run just after being added when test suite is already started
    assert ExUnitServer._async_modules() == []
  end

  test "_loaded/0 allows to retrieve the loaded time" do
    assert is_integer(ExUnitServer._loaded())
  end
end

defmodule ExUnitContinuous.ExUnitServerTest do
  use ExUnit.Case

  alias ExUnitContinuous.ExUnitServer

  test "_sync_modules/1 allows to modify the list of sync_modules on the server" do
    on_exit(fn ->
      ExUnitServer._sync_modules(fn sm -> sm |> List.delete(:fake_module) end)
    end)

    assert :fake_module in ExUnitServer._sync_modules(fn sm -> sm ++ [:fake_module] end)
  end

  test "_async_modules/1 allows to modify the list of async_modules on the server" do
    on_exit(fn ->
      ExUnitServer._async_modules(fn sm -> sm |> List.delete(:fake_module) end)
    end)

    assert :fake_module in ExUnitServer._async_modules(fn sm -> sm ++ [:fake_module] end)
  end

  test "add_async_module/1 adds an async module, or exit cleanly" do
    on_exit(fn ->
      ExUnitServer._async_modules(fn sm ->
        sm |> List.delete(ExUnitContinuous.ExUnitServerASyncTest)
      end)
    end)

    # Note: async test modules are added and taken right away, even while test is running.
    assert :ok ==
             ExUnitContinuous.ExUnitServer.add_async_module(
               ExUnitContinuous.ExUnitServerASyncTest
             )
  end
end
