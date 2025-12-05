import AOC

aoc 2024, 11 do
  @moduledoc """
  https://adventofcode.com/2024/day/11

  Plutonian Pebbles - stones transform on each blink:
  - 0 -> 1
  - even digit count -> split in half
  - else -> multiply by 2024

  Track counts per unique value, not individual stones.
  """

  def p1(input) do
    input
    |> parse()
    |> blink_n(25)
    |> Map.values()
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> blink_n(75)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  defp blink_n(counts, 0), do: counts

  defp blink_n(counts, n) do
    counts
    |> Enum.reduce(%{}, fn {stone, count}, acc ->
      transform(stone)
      |> Enum.reduce(acc, fn new_stone, acc2 ->
        Map.update(acc2, new_stone, count, &(&1 + count))
      end)
    end)
    |> blink_n(n - 1)
  end

  defp transform(0), do: [1]

  defp transform(stone) do
    digits = Integer.digits(stone)
    len = length(digits)

    if rem(len, 2) == 0 do
      {left, right} = Enum.split(digits, div(len, 2))
      [Integer.undigits(left), Integer.undigits(right)]
    else
      [stone * 2024]
    end
  end
end
