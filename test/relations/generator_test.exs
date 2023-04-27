defmodule Relations.GeneratorTest do
  use ExUnit.Case
  doctest Relations.Generator

  alias Relations.Generator

  require ExUnitProperties
  require StreamData


  describe "clauses_and_body/1" do
    

    test "accepts a keyword list of fields and returns clauses and body, usable with with/1 " do
      
      clauses_and_body = Generator.clauses_and_body([f1: :f1_code, f2:  :f2_code ])

      expr = quote do
          with unquote_splicing(clauses_and_body)
        end

      assert Code.eval_quoted(expr) == {[f1: :f1_code, f2: :f2_code], []}

    end


    # TODO : how to test gen and check macros ???
    
    # test "accepts a keyword list of fields and returns clauses and body, usable with ExUnitProperties.gen macro" do
      
    #   clauses_and_body = Generator.clauses_and_body([f1: StreamData.integer(), f2:  StreamData.float() ])

    #   expr =  ExUnitProperties.gen({:all, [], clauses_and_body})
    #     # end |> IO.inspect()

    #     # assert Code.eval(expr) == []
    #   assert Code.eval_quoted(expr) == {[f1: :f1_code, f2: :f2_code], []}

    # end


    # test "accepts a keyword list of fields and returns clauses and body, usable with ExUnitProperties.check macro" do
    #   clauses_and_body = Generator.clauses_and_body([f1: StreamData.integer(), f2:  StreamData.float() ])

    #   expr = quote(do: ExUnitProperties.check all unquote_splicing(clauses_and_body))
        
    #      expr |> IO.inspect()

    #   assert Code.eval_quoted(expr) == {[f1: :f1_code, f2: :f2_code], []}
    # end



  end






end
