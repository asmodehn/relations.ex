defmodule ExUnitContinuous.InterpretedDefaultTest do
  use ExUnit.Case
  # not registering test to not interfere with testing

  test "some sync test" do
    true
  end
end

defmodule ExUnitContinuous.InterpretedSyncTest do
  use ExUnit.Case, async: false
  # not registering test to not interfere with testing

  test "some sync test" do
    true
  end
end

defmodule ExUnitContinuous.InterpretedASyncTest do
  use ExUnitContinuous.Case

  test "some async test" do
    true
  end
end
