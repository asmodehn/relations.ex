# Relations

An Elixir helper package to define relations and corresponding property tests

the main macro defined here are :
- defeq to define an equivalence relation,
- defrel to define a relation (function with two arguments) with the properties it must satisfy,
- reltest to test properties of a relation when running tests 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nope` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:relations, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/nope>.

