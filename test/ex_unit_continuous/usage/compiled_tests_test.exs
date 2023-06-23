defmodule ExUnitContinuous.CompiledTestsTest do
  use ExUnit.Case

  test "ensure_update by compiling module source again" do
    assert [ExUnitContinuous.CompiledASyncTest] ==
             ExUnitContinuous.Updater.ensure_updated(ExUnitContinuous.CompiledASyncTest)
  end

  # VERIFY: Only ASync checks should have run,
  #         Sync checks should be skipped with a warning

  #  import ExUnitContinuous.Runner, only: [run_in_test: 1]

  # Running a second time, on already compiled modules, triggers the tests again

  #  run_in_test(ExUnitContinuous.CompiledSyncTest)
  # VERIFY: this triggers exception.

  # TODO : these seems to be mostly the same...
  #  run_in_test(ExUnitContinuous.CompiledASyncTest)
  ExUnitContinuous.Runner.run([
    ExUnitContinuous.CompiledASyncTest
  ])

  # TODO : maybe an extra "test" (or "describe" ?) macro to support the usecase ?
end
