defmodule Relations.Properties.Utils do
  def string_or_inspect(smth) do
    if is_nil(String.Chars.impl_for(smth)) do
      Kernel.inspect(smth)
    else
      String.Chars.to_string(smth)
    end
  end
end
