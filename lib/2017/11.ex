import AOC

aoc 2017, 11 do
  @moduledoc """
  https://adventofcode.com/2017/day/11
  """

  def p1(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.reduce({0, 0, 0}, &hex_move/2)
    |> hex_distance()
  end

  def p2(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.scan({0, 0, 0}, &hex_move/2)
    |> Enum.map(&hex_distance/1)
    |> Enum.max()
  end

  # Cube coordinates for hex grid
  defp hex_move("n", {x, y, z}), do: {x, y + 1, z - 1}
  defp hex_move("s", {x, y, z}), do: {x, y - 1, z + 1}
  defp hex_move("ne", {x, y, z}), do: {x + 1, y, z - 1}
  defp hex_move("nw", {x, y, z}), do: {x - 1, y + 1, z}
  defp hex_move("se", {x, y, z}), do: {x + 1, y - 1, z}
  defp hex_move("sw", {x, y, z}), do: {x - 1, y, z + 1}

  defp hex_distance({x, y, z}) do
    div(abs(x) + abs(y) + abs(z), 2)
  end
end
