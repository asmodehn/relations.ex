defmodule Relations.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_unit_continuous,
      version: "0.1.0",
      elixir: "~> 1.14",
      # we want ExUnitContinuous to run permanently on dev environment
      start_permanent: Mix.env() in [:prod, :dev],
      description: description(),
      package: package(),
      deps: deps(),

      # options
      elixirc_paths: elixirc_paths(Mix.env()),
      # [warnings_as_errors: true],
      elixirc_options: [],

      # Docs
      name: "Relations",
      source_url: "https://github.com/asmodehn/relations.ex",
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: applications(Mix.env()),
      mod: {ExUnitContinuous.Application, []}
    ]
  end

  # TODO : seem we can get rid of the "application" and keep a simple library here...
  # After all, while keeping things simple the state to keep around is the link module -> source_path
  # And it is stored in the module itself

  # ex_unit is run by mix on test environment
  defp applications(:test), do: [:logger]
  # but for other envs, we need to start ex_unit
  defp applications(_), do: applications(:test) ++ [:ex_unit]

  defp description() do
    "Relations provides macros to run property tests on functions that can be defined as relations."
  end

  defp docs do
    [
      # The main page in the docs
      main: "readme",
      # logo: "path/to/logo.png",
      extras: ["README.md", "DEMO.livemd"]
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* DEMO* LICENSE*),
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/asmodehn/relations.ex"}
    ]
  end

  # Specifies which paths to compile per environment.
  # to be able to interactively use test/usage
  #  defp elixirc_paths(:dev), do: ["lib", "test/ex_unit_continuous/usage"]
  defp elixirc_paths(:test), do: ["lib", "test/ex_unit_continuous/usage", "test/relations/usage"]
  defp elixirc_paths(_), do: ["lib", "test/ex_unit_continuous/usage"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      # since we embed property tests also on dev and prod environments,
      # we always depend on stream_data
      {:stream_data, "~> 0.5"},

      # For development only
      {:committee, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
