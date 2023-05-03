defmodule Relations.Properties do
  @moduledoc ~S"""

  Module gathering all properties tests.

  For each property there is a check macro for the code itself, 
  and a function returning a quoted block with the property and a description string.
  """

  import Relations.Properties.Utils

  alias Relations.Properties.{Empty, Universal, Identity, Reflexive, Symmetric, Transitive}

  defmacro empty(generator, relation, opts \\ [inspect: false]) do
    quote do
      unquote(Empty.quoted_property(generator, relation, opts))
    end
  end

  defmacro universal(generator, relation, opts \\ [inspect: false]) do
    quote do
      unquote(Universal.quoted_property(generator, relation, opts))
    end
  end

  defmacro identity(generator, relation, opts \\ [inspect: false]) do
    quote do
      unquote(Identity.quoted_property(generator, relation, opts))
    end
  end

  defmacro reflexive(generator, relation, opts \\ [inspect: false]) do
    quote do
      unquote(Reflexive.quoted_property(generator, relation, opts))
    end
  end

  defmacro symmetric(generator, relation, opts \\ [descr: nil, inspect: false]) do
    quote do
      unquote(Symmetric.quoted_property(generator, relation, opts))
    end
  end

  # TODO: antisymmetric

  defmacro transitive(generator, relation, opts \\ [descr: nil, inspect: false]) do
    quote do
      unquote(Transitive.quoted_property(generator, relation, opts))
    end
  end

  def describe_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} for #{gen_str}"
  end

  defmacro describe(generator, relation, properties \\ [descr: nil, inspect: false])
           when is_list(properties) do
    # If it is a function that needs to be called (because of late definition for instance)
    # then we call it and quote its result.
    # generator = if is_function(unquote(generator), 0), do: quote(unquote(generator)()), else: generator

    inspect = Keyword.get(properties, :inspect, false)
    descr = Keyword.get(properties, :descr)

    quoted_check =
      properties
      |> Keyword.drop([:inspect, :descr])
      |> Enum.map(fn {k, e} ->
        case {k, e} do
          {:reflexive, true} ->
            quote do:
                    Relations.Properties.reflexive(unquote(generator), unquote(relation),
                      descr: "is reflexive",
                      inspect: unquote(inspect)
                    )

          {:symmetric, true} ->
            quote do:
                    Relations.Properties.symmetric(unquote(generator), unquote(relation),
                      descr: "is symmetric",
                      inspect: unquote(inspect)
                    )

          {:transitive, true} ->
            quote do:
                    Relations.Properties.transitive(unquote(generator), unquote(relation),
                      descr: "is transitive",
                      inspect: unquote(inspect)
                    )

          # TODO : handle false case ? semantics ? need to be compared with not present (ie. no test) 
          unknown ->
            raise RuntimeError, message: "#{Kernel.inspect(unknown)} is not a known property"
        end
      end)

    if descr do
      quote do
        describe unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        describe Relations.Properties.describe_descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  # defmacro describe(generator, relation, properties ) do
  #   IO.inspect([generator, relation, properties])
  # end
end
