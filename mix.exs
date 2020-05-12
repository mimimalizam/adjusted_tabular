defmodule AdjustedTabular.MixProject do
  use Mix.Project

  def project do
    [
      app: :adjusted_tabular,
      version: "0.1.0",
      elixir: "~> 1.10.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:httpoison, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end
