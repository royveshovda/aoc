defmodule D01 do
  @moduledoc """
  Documentation for `D01`.
  """

  def part1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.map(&Enum.sum(&1))
    |> Enum.sort(:desc)
    |> List.first()
  end

  def part2(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.map(&Enum.sum(&1))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

end
