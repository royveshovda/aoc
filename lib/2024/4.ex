import AOC

aoc 2024, 4 do
  @moduledoc """
  https://adventofcode.com/2024/day/4

  Ceres Search - Find XMAS in all directions and X-MAS patterns.
  """

  def p1(input) do
    grid = parse(input)

    directions = [{0,1}, {0,-1}, {1,0}, {-1,0}, {1,1}, {1,-1}, {-1,1}, {-1,-1}]

    for {{x, y}, "X"} <- grid,
        dir <- directions,
        xmas?(grid, {x, y}, dir),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  def p2(input) do
    grid = parse(input)

    for {{x, y}, "A"} <- grid,
        x_mas?(grid, {x, y}),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Map.new()
  end

  defp xmas?(grid, {x, y}, {dx, dy}) do
    word = for i <- 0..3, do: Map.get(grid, {x + i*dx, y + i*dy})
    word == ["X", "M", "A", "S"]
  end

  defp x_mas?(grid, {x, y}) do
    diag1 = [Map.get(grid, {x-1, y-1}), "A", Map.get(grid, {x+1, y+1})]
    diag2 = [Map.get(grid, {x+1, y-1}), "A", Map.get(grid, {x-1, y+1})]

    mas?(diag1) and mas?(diag2)
  end

  defp mas?(chars), do: chars == ["M", "A", "S"] or chars == ["S", "A", "M"]
end
