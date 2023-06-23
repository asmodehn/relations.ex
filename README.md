# Relations

An Elixir helper package to define relations and corresponding property tests

TODO : maybe change name ?? category if we get category to replace `module` with extra semantics ??

the main macro defined here are :
- defeq to define an equivalence relation,
- defrel to define a relation (function with two arguments) with the properties it must satisfy,
- reltest to test properties of a relation when running `mix test`. 

# ExUnitContinuous

ExUnitContinuous is a small extension to ExUnit, allowing a developer to
dynamically run tests on an already running application, on any environment.

It tries its best to not interfere with ExUnit usecases, but adds some more:
- running tests from a script or an already loaded module,
- running tests on any env, including `:prod`.
- running tests via the usual `mix test`

It relies on ExUnit as much as possible 
for test runs, so the configuration is minimal and usage is hopefully 
simple enough, to be picked up on the fly, when the situation demands it.

It is useful when the deployment might not always be the same, 
such as with unstable nodes or unreliable network, 
but there are known logical invariants that an operator can verify at runtime.

## Non Goals

We want an ExUnitContinuous setup to be minimal. Therefore we expect the user to:
- establish a connection on the running BEAM
- run tests interactively, while being able to retrieve the output
Possibly via iex or via livebook for simpler scripting and nicer output.

Therefore, we will leave for other packages to take care of related aspects:
- scheduling test to run at a later time
- outputting test results in various ways
- defining different types of async (side-effect free)
- throttle test runs
- etc.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_unit_continuous` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_unit_continuous, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_unit_continuous>.




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `relations` to your list of dependencies in `mix.exs`:

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

