defmodule Relations.Properties do
  @moduledoc ~S"""

  Module gathering all properties tests.

  For each property there is a check macro for the code itself, 
  and a function returning a quoted block with the property and a description string.
  """

  import Relations.Properties.Utils

  alias Relations.Properties.{Empty, Universal, Identity, Reflexive, Symmetric, Transitive}

  defmacro empty(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr, nil)

    quoted_check =
      Empty.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Empty.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  defmacro universal(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr, nil)

    quoted_check =
      Universal.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Universal.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  defmacro identity(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr, nil)

    quoted_check =
      Identity.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Identity.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  defmacro reflexive(generator, relation, opts \\ [inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr, nil)

    quoted_check =
      Reflexive.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Reflexive.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  defmacro symmetric(generator, relation, opts \\ [descr: nil, inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

    quoted_check =
      Symmetric.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Symmetric.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  # TODO: antisymmetric

  defmacro transitive(generator, relation, opts \\ [descr: nil, inspect: false]) do
    inspect = Keyword.get(opts, :inspect)
    descr = Keyword.get(opts, :descr)

    quoted_check =
      Transitive.quoted_check(
        generator,
        relation,
        inspect: inspect
      )

    if descr do
      quote do
        property unquote(descr) do
          unquote(quoted_check)
        end
      end
    else
      quote do
        property Transitive.descr(unquote(generator), unquote(relation)) do
          unquote(quoted_check)
        end
      end
    end
  end

  def describe_descr(generator, relation) do
    rel_str = string_or_inspect(relation)

    gen_str = string_or_inspect(generator)

    "#{rel_str} for #{gen_str}"
  end

  defmacro describe(generator, relation, properties \\ [])
           when is_list(properties)
           when is_map(properties) do
    # If it is a function that needs to be called (because of late definition for instance)
    # then we call it and quote its result.
    # generator = if is_function(unquote(generator), 0), do: quote(unquote(generator)()), else: generator

    inspect = Keyword.get(properties, :inspect, false)

    prop_checks =
      properties
      |> Keyword.drop([:inspect])
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

    quote location: :keep do
      describe Relations.Properties.describe_descr(unquote(generator), unquote(relation)) do
        unquote(prop_checks)
      end
    end
  end

  # defmacro describe(generator, relation, properties ) do
  #   IO.inspect([generator, relation, properties])
  # end
end
