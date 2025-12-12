import AOC

aoc 2016, 3 do
  @moduledoc """
  https://adventofcode.com/2016/day/3
  Day 3: Squares With Three Sides
  Count valid triangles.
  """

  def p1(input) do
    input
    |> parse_triangles()
    |> Enum.count(&valid_triangle?/1)
  end

  def p2(input) do
    input
    |> parse_triangles()
    |> Enum.chunk_every(3)
    |> Enum.flat_map(&transpose/1)
    |> Enum.count(&valid_triangle?/1)
  end

  defp parse_triangles(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp valid_triangle?({a, b, c}) do
    a + b > c and a + c > b and b + c > a
  end

  defp transpose([{a1, a2, a3}, {b1, b2, b3}, {c1, c2, c3}]) do
    [{a1, b1, c1}, {a2, b2, c2}, {a3, b3, c3}]
  end
end
