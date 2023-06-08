defmodule Relations.Properties do
  @moduledoc ~S"""

  Module gathering all properties tests.

  For each property there is a check macro for the code itself, 
  and a function returning a quoted block with the property and a description string.
  """

  alias Relations.Properties.Utils

  alias Relations.Properties.{
    Empty,
    Universal,
    Identity,
    Reflexive,
    Symmetric,
    Transitive,
    Antisymmetric
  }

  defmodule DefProperties do
    defstruct kind: nil,
              fun: nil,
              args: nil,
              guards: nil,
              body: nil,
              properties: nil,
              attrs: nil
  end

  @valid_properties [
    :transitive,
    :symmetric,
    :associative,
    :reflexive,
    :antisymmetric
  ]

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

  defmacro antisymmetric(generator, relation, opts \\ [descr: nil, inspect: false]) do
    quote do
      unquote(Antisymmetric.quoted_property(generator, relation, opts))
    end
  end

  defmacro transitive(generator, relation, opts \\ [descr: nil, inspect: false]) do
    quote do
      unquote(Transitive.quoted_property(generator, relation, opts))
    end
  end

  #
  #  def describe_descr(generator, relation) do
  #    rel_str = Utils.string_or_inspect(relation)
  #
  #    gen_str = Utils.string_or_inspect(generator)
  #
  #    "#{rel_str} for #{gen_str}"
  #  end

  defmacro __using__(opts \\ []) do
    quote do
      Relations.Properties.__register__(__MODULE__, unquote(opts))
    end
  end

  # Ref: https://github.com/arjan/decorator/blob/master/lib/decorator/decorate.ex
  def __on_definition__(env, kind, fun, args, guards, body) do
    properties = Module.get_attribute(env.module, :property)

    attrs = extract_attributes(env.module, body)

    with_properties = %DefProperties{
      kind: kind,
      fun: fun,
      args: args,
      guards: guards,
      body: body,
      properties:
        properties
        |> Enum.map(fn
          [{k, v}] when k in @valid_properties -> {k, v}
        end),
      attrs: attrs
    }

    Module.put_attribute(env.module, :with_properties, with_properties)
    Module.delete_attribute(env.module, :property)
  end

  defp extract_attributes(module, body) do
    Macro.postwalk(body, %{}, fn
      {:@, _, [{attr, _, nil}]} = n, attrs ->
        attrs = Map.put(attrs, attr, Module.get_attribute(module, attr))
        {n, attrs}

      n, acc ->
        {n, acc}
    end)
    |> elem(1)
  end

  def __register__(module, opts) do
    unless Keyword.keyword?(opts) do
      raise ArgumentError,
            ~s(the argument passed to "use Relations.Properties" must be a list of options, ) <>
              ~s(got: #{inspect(opts)})
    end

    property_check = Enum.any?([:property], &Module.has_attribute?(module, &1))

    if property_check do
      raise "you must set @property after the call to \"use Relations.Properties\""
    end

    accumulate_attributes = [
      # property attribute
      :property,
      # property with functions (copied from decorator.ex)
      :with_properties
    ]

    Enum.each(accumulate_attributes, &Module.register_attribute(module, &1, accumulate: true))

    #      if Keyword.get(opts, :register, true) do
    #        Module.put_attribute(module, :after_compile, __MODULE__)
    #      end

    Module.put_attribute(module, :before_compile, __MODULE__)
    Module.put_attribute(module, :on_definition, __MODULE__)
  end

  @doc false
  defmacro __before_compile__(env) do
    properties =
      Module.get_attribute(env.module, :with_properties)
      |> Enum.map(fn
        %DefProperties{kind: :def, fun: name, args: args, properties: props} ->
          quoted_properties_test(Function.capture(env.module, name, length(args)), props)
      end)

    quote do
      # nested module
      defmodule Properties do
        use ExUnit.Case, async: true

        use ExUnitProperties

        unquote_splicing(properties)
      end
    end
  end

  defmacro properties_test(relation, properties \\ [inspect: false])
           when is_list(properties) do
    quoted_properties_test(relation, properties)
  end

  def quoted_properties_test(relation, properties \\ [inspect: false])
      when is_list(properties) do
    inspect = Keyword.get(properties, :inspect, false)
    #    descr = Keyword.get(properties, :descr)

    # TODO :assert generator is like &mygen/0

    properties
    |> Keyword.drop([:inspect, :descr])
    |> Enum.map(fn {k, e} ->
      case {k, e} do
        {:reflexive, generator} ->
          quote do:
                  Relations.Properties.reflexive(unquote(generator).(), unquote(relation),
                    descr:
                      "#{Utils.string_or_inspect(unquote(relation))} is reflexive for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        {:symmetric, generator} ->
          quote do:
                  Relations.Properties.symmetric(unquote(generator).(), unquote(relation),
                    descr:
                      "#{Utils.string_or_inspect(unquote(relation))} is symmetric for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        {:transitive, generator} ->
          quote do:
                  Relations.Properties.transitive(unquote(generator).(), unquote(relation),
                    descr:
                      "#{Utils.string_or_inspect(unquote(relation))} is transitive for #{Utils.string_or_inspect(unquote(generator))}",
                    inspect: unquote(inspect)
                  )

        # TODO : handle false case ? semantics ? need to be compared with not present (ie. no test) 
        unknown ->
          raise RuntimeError, message: "#{Kernel.inspect(unknown)} is not a known property"
      end
    end)
  end

  defmacro verify(module, _opts \\ []) do
    caller = __CALLER__

    require =
      if is_atom(Macro.expand(module, caller)) do
        quote do
          require unquote(module)
        end
      end

    prop_module_plural =
      quote do
        ExUnit.plural_rule(
          Utils.string_or_inspect(Module.concat([unquote(module), Properties])),
          Utils.string_or_inspect(Module.concat([unquote(module), Properties]))
        )
      end

    tests =
      quote bind_quoted: [
              module: module,
              env_line: caller.line,
              env_file: caller.file
            ] do
        prop_module = Module.concat([module, Properties])

        # gathering relation property tests
        for {reltest_name, one} <-
              prop_module.__info__(:functions)
              |> Enum.filter(fn {n, a} ->
                n != :relation and
                  not String.starts_with?(Atom.to_string(n), "__")
              end) do
          t =
            ExUnit.Case.register_test(
              __MODULE__,
              env_file,
              env_line,
              Utils.string_or_inspect(prop_module),
              reltest_name,
              []
            )

          def unquote(t)(_) do
            # calling reltest_name test from relationtest module, with module and relation in context

            apply(unquote(prop_module), unquote(reltest_name), [
              %{module: unquote(module)}
            ])
          end
        end
      end

    [require, prop_module_plural, tests]
  end
end
