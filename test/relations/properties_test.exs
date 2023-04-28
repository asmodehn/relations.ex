defmodule Relations.PropertiesTest do
  use ExUnit.Case
  doctest Relations.Properties

  alias Relations.Properties




  describe "reflexive/2" do

    setup do
      

        :ok
      
    end




    # test "generate a property test for a reflexive relation" do
    #   {:property, _ctx, _contents} = Properties.reflexive(StreamData.integer(), &Kernel.div/2)
      


    # end
  

  end

  

  # describe "Known reflexive relations" do

  #   use ExUnitProperties

  #   Properties.reflexive(StreamData.integer(), &Kernel.div/2)

  #   Properties.reflexive(StreamData.integer(), &Kernel.==/2)


  # end

  describe "symmetric/2" do
    
      use ExUnitProperties

      Properties.symmetric(StreamData.integer, &Kernel.==/2, inspect: true)

  end





end