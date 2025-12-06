import AOC

aoc 2021, 9 do
  @moduledoc """
  Day 9: Smoke Basin

  Find low points and basins in heightmap.
  Part 1: Sum risk levels of low points
  Part 2: Find three largest basins
  """

  @doc """
  Part 1: Find cells lower than all 4 neighbors, sum (height + 1).

  ## Examples

      iex> p1("2199943210\\n3987894921\\n9856789892\\n8767896789\\n9899965678")
      15
  """
  def p1(input) do
    grid = parse(input)

    grid
    |> low_points()
    |> Enum.map(fn {pos, _} -> Map.get(grid, pos) + 1 end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Find basins (flood fill from low points to 9s), multiply 3 largest.

  ## Examples

      iex> p2("2199943210\\n3987894921\\n9856789892\\n8767896789\\n9899965678")
      1134
  """
  def p2(input) do
    grid = parse(input)

    grid
    |> low_points()
    |> Enum.map(fn {pos, _} -> basin_size(grid, pos) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp low_points(grid) do
    Enum.filter(grid, fn {{x, y}, height} ->
      neighbors = [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

      Enum.all?(neighbors, fn neighbor ->
        case Map.get(grid, neighbor) do
          nil -> true
          neighbor_height -> height < neighbor_height
        end
      end)
    end)
  end

  defp basin_size(grid, start) do
    bfs([start], MapSet.new([start]), grid)
    |> MapSet.size()
  end

  defp bfs([], visited, _grid), do: visited

  defp bfs([{x, y} | rest], visited, grid) do
    neighbors =
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.filter(fn pos ->
        case Map.get(grid, pos) do
          nil -> false
          9 -> false
          _ -> not MapSet.member?(visited, pos)
        end
      end)

    new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
    bfs(rest ++ neighbors, new_visited, grid)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, String.to_integer(char)} end)
    end)
    |> Map.new()
  end
end
