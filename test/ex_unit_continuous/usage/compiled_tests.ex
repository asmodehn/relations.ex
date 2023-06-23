defmodule ExUnitContinuous.CompiledDefaultTest do
  @moduledoc false

  use ExUnit.Case

  test "some sync (by default) test" do
    true
  end
end

defmodule ExUnitContinuous.CompiledSyncTest do
  @moduledoc false

  use ExUnit.Case, async: false

  test "some sync test" do
    true
  end
end

defmodule ExUnitContinuous.CompiledASyncTest do
  @moduledoc false

  use ExUnitContinuous.Case

  test "some async test" do
    true
  end
end
