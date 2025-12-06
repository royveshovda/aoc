import AOC

aoc 2022, 12 do
  @moduledoc """
  Day 12: Hill Climbing Algorithm

  Find shortest path up hill (can only go up 1 level, down any).
  Part 1: From S to E.
  Part 2: From any 'a' to E.
  """

  @doc """
  Part 1: Shortest path from S to E.

  ## Examples

      iex> example = "Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi"
      iex> p1(example)
      31
  """
  def p1(input) do
    {grid, start, target} = parse(input)
    bfs(grid, [start], target, MapSet.new([start]), 0)
  end

  @doc """
  Part 2: Shortest path from any 'a' elevation to E.

  ## Examples

      iex> example = "Sabqponm\\nabcryxxl\\naccszExk\\nacctuvwj\\nabdefghi"
      iex> p2(example)
      29
  """
  def p2(input) do
    {grid, _start, target} = parse(input)

    # Find all positions with elevation 'a' (or S which equals 'a')
    starts =
      grid
      |> Enum.filter(fn {_pos, h} -> h == ?a end)
      |> Enum.map(fn {pos, _} -> pos end)

    bfs(grid, starts, target, MapSet.new(starts), 0)
  end

  defp parse(input) do
    rows = String.split(input, "\n", trim: true)

    {grid, start, target} =
      rows
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil, nil}, fn {row, y}, acc ->
        row
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, x}, {grid, start, target} ->
          pos = {x, y}
          case char do
            ?S -> {Map.put(grid, pos, ?a), pos, target}
            ?E -> {Map.put(grid, pos, ?z), start, pos}
            _ -> {Map.put(grid, pos, char), start, target}
          end
        end)
      end)

    {grid, start, target}
  end

  defp bfs(_grid, [], _target, _visited, _steps), do: nil
  defp bfs(grid, frontier, target, visited, steps) do
    if Enum.member?(frontier, target) do
      steps
    else
      next_frontier =
        frontier
        |> Enum.flat_map(fn pos -> neighbors(grid, pos, visited) end)
        |> Enum.uniq()

      new_visited = Enum.reduce(next_frontier, visited, &MapSet.put(&2, &1))
      bfs(grid, next_frontier, target, new_visited, steps + 1)
    end
  end

  defp neighbors(grid, {x, y}, visited) do
    current_height = grid[{x, y}]

    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn pos ->
      height = Map.get(grid, pos)
      height != nil and
        not MapSet.member?(visited, pos) and
        height <= current_height + 1
    end)
  end
end
