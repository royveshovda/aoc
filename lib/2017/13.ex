import AOC

aoc 2017, 13 do
  @moduledoc """
  https://adventofcode.com/2017/day/13
  """

  def p1(input) do
    layers = parse(input)

    layers
    |> Enum.filter(fn {depth, range} -> caught?(depth, range, 0) end)
    |> Enum.map(fn {depth, range} -> depth * range end)
    |> Enum.sum()
  end

  def p2(input) do
    layers = parse(input)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(fn delay ->
      not Enum.any?(layers, fn {depth, range} -> caught?(depth, range, delay) end)
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [depth, range] = String.split(line, ": ")
      {String.to_integer(depth), String.to_integer(range)}
    end)
  end

  defp caught?(depth, range, delay) do
    rem(depth + delay, 2 * (range - 1)) == 0
  end
end
