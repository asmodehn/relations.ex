defmodule Relations.Generator do
	
  defmacro __using__(_opts) do

    quote do

    	import Relations.Generator , only: [defgen: 1]
    	

    end
  end


  defmacro defgen(fields) do

  	_caller = __CALLER__


  	clauses_and_body = clauses_and_body(fields)

  	quote  do
  		require ExUnitProperties
  		import StreamData

	    def generator() do
	     ExUnitProperties.gen all unquote_splicing(clauses_and_body)
	  	end
	  	
	  end 


	    	# unquote(args) |> Enum.into(%unquote(caller){})
  end


  @spec clauses_and_body(Keyword.t()) :: {Keyword.t(), List.t()}
  def clauses_and_body(fields) do
  	
  	args = Macro.generate_unique_arguments( length(fields), __MODULE__ )

  	{args, clauses} = fields
  	|> Enum.zip(args)
  	|> Enum.map(fn {{k, g}, a} ->
  		{{k, a},
  		 quote do
  			unquote(a) <- unquote(g) 
  		end}
  	 end)
  	|> Enum.unzip()

  	clauses ++ [[do: args]] |> IO.inspect()
  end
  	


end