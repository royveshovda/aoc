defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:advent_of_code_utils, "~> 5.0.2", override: true},
      {:nimble_parsec, "~> 1.4.2"},
      # {:arrays, "~> 2.1.1"}, # Temporarily disabled due to type_check incompatibility with Elixir 1.19
      {:heap, "~> 3.0"},
      {:qex, "~> 0.5"},
      {:memoize, "~> 1.4.4"},
      {:mix_test_watch, "~> 1.4.0", only: :dev},
      {:credo, "~> 1.7.14", only: [:dev, :test], runtime: false}
    ]
  end
end
