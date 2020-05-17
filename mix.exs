defmodule AdjustedTabular.MixProject do
  use Mix.Project

  def project do
    [
      app: :adjusted_tabular,
      version: "0.1.0",
      elixir: "~> 1.10.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      applications: [:postgrex],
      extra_applications: [:logger],
      mod: {AdjustedTabular.Application, []}
    ]
  end

  defp deps do
    [
      {:postgrex, "~> 0.15.4"},
      {:plug, "~> 1.9.0"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, ">= 0.0.0", only: [:dev, :test]},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
