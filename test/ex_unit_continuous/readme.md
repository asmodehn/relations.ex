# Tests for ExUnitContinuous

In here we depart from the usual ExUnit setup, as we want to test ExContinuous itself,
while running the tests, and let ExUnitContinuous manage ExUnit appropriately doing so.

Therefore the tests here have a filename in "*.ex" and are also *NOT COMPILED* by the mix project.
Instead this is done dynamically when the test is running, via ExUnitContinuous.

More accurately, this is how the macros from ExUnitContinuous are tested (in test/ex_unit_continuous.exs), 
which is started by ExUnit as usual. ExUnitContinuous macros detect when they are running as part of a ExUnit.Case,
and behave appropriately in this case. 

