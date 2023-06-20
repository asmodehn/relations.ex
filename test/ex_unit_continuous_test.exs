defmodule ExUnitContinuousTest do
  use ExUnit.Case, async: true
  #  doctest ExUnitContinuous

  # WARNING: this test compiles on the fly other tests in usage/test subfolder
  # in order to test them dynamically

  # This allows ExUnit, to test ExUnitContinuous,
  # while transitively testing properties test usage examples.

  # Multiple ways to run a test module from a running test suite:
  # 1. pass a module name, or a file path to compile, to &run_in_test/1
  import ExUnitContinuous.Runner, only: [run_in_test: 1]

  if Code.ensure_loaded?(ExUnitContinuous.RunnerTest) do
    run_in_test(ExUnitContinuous.RunnerTest)
  else
    run_in_test("test/ex_unit_continuous/runner_test.ex.nowarn")
  end

  # 2. Pass multiple modules or filepaths to &run_in_test/1
  # Also works with module atoms if they are already loaded
  #  run_in_test(["test/ex_unit_continuous/runner_test.ex.nowarn", ExUnitContinuous.RunnerTest])
  # TODO : use different tests to avoid useless testing...

  # BTW: Note how a non-loaded module name triggers an error:
  #  run_in_test(UnloadedModule)

  # 3. Use the main ExUnitContinuous.run/1 with a list of modules or filepaths.
  # It will detect if it is running from a ExUnit.Case module, and adapt accordingly
  #  import ExUnitContinuous, only: [run: 1]
  #  run([ExUnitContinuous.RunnerTest, "test/ex_unit_continuous/runner_test.ex.nowarn"])
  # Note you can also use this function to run a test on an already running non-test environment

  #  test "runs test/usage/test/*.exs" do
  #    tests = Path.wildcard("test/usage/test/*.exs")
  #    assert ExUnitContinuous.run_after_current(tests) ==  :ok  #%{excluded: 0, failures: 0, skipped: 0, total: 8}
  #
  #  end
end
