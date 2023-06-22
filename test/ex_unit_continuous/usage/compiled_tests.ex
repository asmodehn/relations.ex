defmodule ExUnitContinuous.CompiledDefaultTest do
    use ExUnit.Case

    test "some sync (by default) test" do
      true
    end

  end

  defmodule ExUnitContinuous.CompiledSyncTest do
    use ExUnit.Case, async: false

    test "some sync test" do
      true
    end

  end



  defmodule ExUnitContinuous.CompiledASyncTest do
    use ExUnitContinuous.Case


    test "some async test" do
      true
    end

  end
