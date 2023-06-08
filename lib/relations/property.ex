defmodule Relations.Property do
  @moduledoc ~S"""

  A property test, or a list of it.
  """

  alias Relations.Properties.Utils

  defstruct capture: nil,
            properties: []

  @valid_properties [
    :transitive,
    :symmetric,
    :associative,
    :reflexive,
    :antisymmetric
  ]

  def new(capture, properties) do
    %__MODULE__{
      capture: capture,
      properties:
        properties
        |> Enum.map(fn
          [{k, v}] when k in @valid_properties -> {k, v}
        end)
    }
  end

  defmacro expand(capture, properties_and_opts \\ [inspect: false]) do
    require =
      quote do
        require Relations.Properties
      end

    inspect = Keyword.get(properties_and_opts, :inspect, false)

    property_tests =
      quoted_expand(
        %__MODULE__{
          capture: capture,
          properties: properties_and_opts |> Keyword.drop([:inspect])
        },
        inspect: inspect
      )

    [require, property_tests]
  end

  def quoted_expand(
        %__MODULE__{
          capture: capture,
          properties: properties
        },
        opts \\ [inspect: false]
      )
      when is_list(properties) do
    inspect = Keyword.get(opts, :inspect, false)
    #    descr = Keyword.get(properties, :descr)

    # TODO :assert generator is like &mygen/0

    properties
    |> Keyword.drop([:inspect, :descr])
    |> Enum.map(fn {k, e} ->
      case {k, e} do
        {:reflexive, generator} ->
          quote do:
                  Relations.Properties.reflexive(unquote(generator).(), unquote(capture),
                    descr:
                      "#{Utils.string_or_inspect(unquote(capture))} is reflexive for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        {:symmetric, generator} ->
          quote do:
                  Relations.Properties.symmetric(unquote(generator).(), unquote(capture),
                    descr:
                      "#{Utils.string_or_inspect(unquote(capture))} is symmetric for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        {:transitive, generator} ->
          quote do:
                  Relations.Properties.transitive(unquote(generator).(), unquote(capture),
                    descr:
                      "#{Utils.string_or_inspect(unquote(capture))} is transitive for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        # TODO : handle false case ? semantics ? need to be compared with not present (ie. no test)
        unknown ->
          raise RuntimeError, message: "#{Kernel.inspect(unknown)} is not a known property"
      end
    end)
  end
end
