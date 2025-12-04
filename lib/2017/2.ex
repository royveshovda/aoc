import AOC

aoc 2017, 2 do
  @moduledoc """
  https://adventofcode.com/2017/day/2
  """

  def p1(input) do
    input
    |> parse_spreadsheet()
    |> Enum.map(fn row ->
      Enum.max(row) - Enum.min(row)
    end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse_spreadsheet()
    |> Enum.map(&find_divisible/1)
    |> Enum.sum()
  end

  defp parse_spreadsheet(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split() |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_divisible(row) do
    for a <- row, b <- row, a > b, rem(a, b) == 0 do
      div(a, b)
    end
    |> List.first()
  end
end
