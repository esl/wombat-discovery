defmodule Wombat.MixProject do
  use Mix.Project

  def project do
    [
      app: :wombat_discovery,
      version: "1.0.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      dialyzer: [flags: [:error_handling, :race_conditions, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WombatDiscovery.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:mock, "~> 0.3.0", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Make wombat discover the node after host change. Visit our repository for more information: https://github.com/esl/wombat-discovery"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "wombat_discovery",
      # These are the default files included in the package
      maintainers: ["Erlang Solutions Ltd"],
      licenses: ["MIT"],
      links: %{}
    ]
  end
end
