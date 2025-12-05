import AOC

aoc 2024, 10 do
  @moduledoc """
  https://adventofcode.com/2024/day/10

  Hoof It - Count reachable 9s (score) and distinct paths (rating).
  """

  def p1(input) do
    grid = parse(input)
    trailheads = for {pos, 0} <- grid, do: pos

    trailheads
    |> Enum.map(fn start -> count_reachable_nines(grid, start) end)
    |> Enum.sum()
  end

  def p2(input) do
    grid = parse(input)
    trailheads = for {pos, 0} <- grid, do: pos

    trailheads
    |> Enum.map(fn start -> count_distinct_paths(grid, start) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} ->
        height = if c == ".", do: -1, else: String.to_integer(c)
        {{x, y}, height}
      end)
    end)
    |> Map.new()
  end

  defp count_reachable_nines(grid, start) do
    bfs(grid, [start], MapSet.new([start]))
    |> Enum.count(fn pos -> grid[pos] == 9 end)
  end

  defp bfs(_grid, [], visited), do: visited
  defp bfs(grid, queue, visited) do
    new_positions =
      queue
      |> Enum.flat_map(fn pos -> neighbors(grid, pos) end)
      |> Enum.reject(&MapSet.member?(visited, &1))
      |> Enum.uniq()

    new_visited = Enum.reduce(new_positions, visited, &MapSet.put(&2, &1))
    bfs(grid, new_positions, new_visited)
  end

  defp neighbors(grid, {x, y}) do
    current = Map.get(grid, {x, y})

    [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
    |> Enum.filter(fn pos ->
      case Map.get(grid, pos) do
        nil -> false
        h -> h == current + 1
      end
    end)
  end

  defp count_distinct_paths(grid, start) do
    dfs_count(grid, start)
  end

  defp dfs_count(grid, pos) do
    case Map.get(grid, pos) do
      9 -> 1
      current ->
        [{elem(pos, 0)+1, elem(pos, 1)},
         {elem(pos, 0)-1, elem(pos, 1)},
         {elem(pos, 0), elem(pos, 1)+1},
         {elem(pos, 0), elem(pos, 1)-1}]
        |> Enum.filter(fn p -> Map.get(grid, p) == current + 1 end)
        |> Enum.map(&dfs_count(grid, &1))
        |> Enum.sum()
    end
  end
end
