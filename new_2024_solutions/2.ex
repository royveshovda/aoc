import AOC

aoc 2024, 2 do
  @moduledoc """
  https://adventofcode.com/2024/day/2

  Red-Nosed Reports - Check monotonic sequences with bounded differences.
  """

  def p1(input) do
    input
    |> parse()
    |> Enum.count(&safe?/1)
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.count(&safe_with_dampener?/1)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split() |> Enum.map(&String.to_integer/1)
    end)
  end

  defp safe?(levels) do
    diffs = levels |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)

    all_increasing = Enum.all?(diffs, &(&1 >= 1 and &1 <= 3))
    all_decreasing = Enum.all?(diffs, &(&1 >= -3 and &1 <= -1))

    all_increasing or all_decreasing
  end

  defp safe_with_dampener?(levels) do
    safe?(levels) or
      Enum.any?(0..(length(levels) - 1), fn i ->
        levels |> List.delete_at(i) |> safe?()
      end)
  end
end
