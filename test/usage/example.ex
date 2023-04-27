defmodule Example do


	defstruct int: 0,
	          mod: 8



	use Relations.Generator

	defgen int: integer(),
		   mod: integer() |> filter(fn x -> x <= 8 end)


	# TODO : doctests

	use Relations

	# defrel equal?(l, r), reflexive: true, symmetric: true, transitive: true do
	# 	rem(l.int, l.mod) == rem(r.div, r.mod)
	# end



end