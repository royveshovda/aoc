import AOC

aoc 2022, 12 do
  def p1(input) do
    {grid, start, goal} = parse(input)
    bfs([{start, 0}], grid, goal, MapSet.new([start]))
  end

  defp bfs([], _grid, _target, _visited), do: :not_found

  defp bfs([{coord, moves} | _tail], _grid, coord, _visited), do: moves

  defp bfs([{coord, moves} | tail], grid, target, visited) do
    next =
      valid_moves(coord, grid)
      |> Enum.filter(&(!MapSet.member?(visited, &1)))
      |> Enum.map(&{&1, moves + 1})

    queue = tail ++ next
    bfs(queue, grid, target, MapSet.union(visited, MapSet.new(next |> Enum.map(&elem(&1, 0)))))
  end

  defp valid_moves({row, col}, grid) do
    cur_height = grid[{row, col}]
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {x, y} -> {row + x, col + y} end)
    |> Enum.filter(&Map.has_key?(grid, &1))
    |> Enum.filter(fn coord -> grid[coord] - cur_height <= 1 end) # Only allowed to climb one. Can go down any amount.
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.reduce({%{}, 0, 0}, fn {line, row}, accout ->
      to_charlist(line)
      |> Enum.with_index(1)
      |> Enum.reduce(accout, fn {char, col}, {grid, start, stop} ->
        coord = {row, col}

        case char do
          ?S -> {Map.put(grid, coord, ?a), coord, stop}
          ?E -> {Map.put(grid, coord, ?z), start, coord}
          _ -> {Map.put(grid, coord, char), start, stop}
        end
      end)
    end)
  end

  def p2(input) do
    {grid, _start, goal} = parse(input)

    Map.filter(grid, fn {_, h} -> h == ?a end)
    |> Map.keys()
    |> Enum.map(fn coord -> bfs([{coord, 0}], grid, goal, MapSet.new([coord])) end)
    |> Enum.reject(&(&1 == :not_found))
    |> Enum.min()
  end
end
