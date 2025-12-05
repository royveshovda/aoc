import AOC

aoc 2024, 11 do
  @moduledoc """
  https://adventofcode.com/2024/day/11
  """
  use Memoize

  def p1(input) do
    stones =
      input
      |> String.trim("\n") |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    stones
    |> Enum.map(& count(&1, 25))
    |> Enum.sum()
  end

  def p2(input) do
    stones =
      input
      |> String.trim("\n") |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    stones
    |> Enum.map(& count(&1, 75))
    |> Enum.sum()
  end

  def blink(0), do: [1]

  def blink(stone) do
    digits = to_string(stone)
    n = String.length(digits)
    if rem(n, 2) == 0 do
      half = div(n, 2)
      [String.slice(digits, 0, half) |> String.to_integer(),
        String.slice(digits, half, half) |> String.to_integer(),
      ]
    else
      [2024 * stone]
    end
  end

  def count(_, 0) do
    1
  end

  defmemo count(stone, n) do
    blink(stone)
    |> Enum.map(& count(&1, n - 1))
    |> Enum.sum()
  end
end
