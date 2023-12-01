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
      {:advent_of_code_utils, "~> 4.0"},
      {:nimble_parsec, "~> 1.4"},
      {:heap, "~> 3.0"},
      {:qex, "~> 0.5"}
    ]
  end
end
