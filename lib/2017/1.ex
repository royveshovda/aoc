import AOC

aoc 2017, 1 do
  @moduledoc """
  https://adventofcode.com/2017/day/1
  """

  def p1(input) do
    digits = input |> String.trim() |> String.graphemes() |> Enum.map(&String.to_integer/1)
    solve(digits, 1)
  end

  def p2(input) do
    digits = input |> String.trim() |> String.graphemes() |> Enum.map(&String.to_integer/1)
    offset = div(length(digits), 2)
    solve(digits, offset)
  end

  defp solve(digits, offset) do
    len = length(digits)
    digits
    |> Enum.with_index()
    |> Enum.reduce(0, fn {digit, i}, acc ->
      next_digit = Enum.at(digits, rem(i + offset, len))
      if digit == next_digit, do: acc + digit, else: acc
    end)
  end
end
