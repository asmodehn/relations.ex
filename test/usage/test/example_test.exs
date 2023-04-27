defmodule ExampleTest do
	use ExUnit.Case

	require Example

	use ExUnitProperties
	
	# doctest Example

	# reltest Example, &equal/2


	property "generator test" do
		
		check all v <- Example.generator() do
			
			[int: i, mod: m] = v 
			assert is_integer(i)
			assert is_integer(m)

		end 



	end

end