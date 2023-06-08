defmodule Relations.Property.Decorator do
  @moduledoc ~S"""
    Module holding the necessary compilation functions to provide a @property decorator.
  """

  defmacro __using__(opts \\ []) do
    quote do
      Relations.Property.Decorator.__register__(__MODULE__, unquote(opts))
    end
  end

  # Inspiration: https://github.com/arjan/decorator/blob/master/lib/decorator/decorate.ex
  def __on_definition__(env, :def, fun, args, _guards, _body) do
    properties = Module.get_attribute(env.module, :property)

    with_properties =
      Relations.Property.new(
        Function.capture(env.module, fun, length(args)),
        properties
      )

    Module.put_attribute(env.module, :with_properties, with_properties)
    Module.delete_attribute(env.module, :property)
  end

  def __register__(module, opts) do
    unless Keyword.keyword?(opts) do
      raise ArgumentError,
            ~s(the argument passed to "use Relations.Property.Decorator" must be a list of options, ) <>
              ~s(got: #{inspect(opts)})
    end

    property_check = Enum.any?([:property], &Module.has_attribute?(module, &1))

    if property_check do
      raise "you must set @property after the call to \"use Relations.Property.Decorator\""
    end

    accumulate_attributes = [
      # property attribute
      :property,
      # property with functions (copied from decorator.ex)
      :with_properties
    ]

    Enum.each(accumulate_attributes, &Module.register_attribute(module, &1, accumulate: true))

    Module.put_attribute(module, :before_compile, __MODULE__)
    Module.put_attribute(module, :on_definition, __MODULE__)
  end

  @doc false
  defmacro __before_compile__(env) do
    properties =
      Module.get_attribute(env.module, :with_properties)
      |> Enum.map(&Relations.Property.quoted_expand/1)

    quote do
      # nested module
      defmodule Properties do
        use ExUnit.Case, async: true
        use ExUnitProperties

        require Relations.Properties

        unquote_splicing(properties)
      end
    end
  end
end
