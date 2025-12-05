import AOC

aoc 2024, 16 do
  @moduledoc """
  https://adventofcode.com/2024/day/16

  Reindeer Maze - Dijkstra with direction state.
  Cost: 1 for move, 1000 for turn.
  P1: minimum cost to reach end.
  P2: count all tiles on any best path.
  """

  @dirs [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

  def p1(input) do
    {grid, start, goal} = parse(input)
    {cost, _paths} = dijkstra(grid, start, goal)
    cost
  end

  def p2(input) do
    {grid, start, goal} = parse(input)
    {_cost, tiles} = dijkstra(grid, start, goal)
    MapSet.size(tiles)
  end

  defp parse(input) do
    {grid, start, goal} =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil, nil}, fn {row, y}, {g, s, e} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({g, s, e}, fn {c, x}, {g2, s2, e2} ->
          pos = {x, y}

          case c do
            "#" -> {g2, s2, e2}
            "S" -> {Map.put(g2, pos, "."), pos, e2}
            "E" -> {Map.put(g2, pos, "."), s2, pos}
            _ -> {Map.put(g2, pos, c), s2, e2}
          end
        end)
      end)

    {grid, start, goal}
  end

  defp dijkstra(grid, start, goal) do
    # State: {pos, dir_index}, start facing east (index 0)
    init_state = {start, 0}
    heap = Heap.new(fn {a, _, _}, {b, _, _} -> a < b end) |> Heap.push({0, init_state, [start]})
    do_dijkstra(heap, grid, goal, %{}, nil, MapSet.new())
  end

  defp do_dijkstra(heap, grid, goal, best, best_cost, tiles) do
    if Heap.empty?(heap) do
      {best_cost, tiles}
    else
      {cost, state, path} = Heap.root(heap)
      heap = Heap.pop(heap)
      {pos, dir_idx} = state

      cond do
        best_cost != nil and cost > best_cost ->
          {best_cost, tiles}

        pos == goal ->
          # Found a best path
          new_tiles = MapSet.union(tiles, MapSet.new(path))

          if best_cost == nil do
            do_dijkstra(heap, grid, goal, best, cost, new_tiles)
          else
            do_dijkstra(heap, grid, goal, best, best_cost, new_tiles)
          end

        Map.get(best, state, :infinity) < cost ->
          # Already found better path to this state
          do_dijkstra(heap, grid, goal, best, best_cost, tiles)

        true ->
          best = Map.put(best, state, cost)

          # Generate moves: forward, turn left, turn right
          {dx, dy} = Enum.at(@dirs, dir_idx)
          {x, y} = pos
          forward_pos = {x + dx, y + dy}

          heap =
            if Map.has_key?(grid, forward_pos) do
              new_state = {forward_pos, dir_idx}
              new_cost = cost + 1

              if new_cost <= Map.get(best, new_state, :infinity) do
                Heap.push(heap, {new_cost, new_state, [forward_pos | path]})
              else
                heap
              end
            else
              heap
            end

          # Turn left (counterclockwise)
          left_idx = Integer.mod(dir_idx - 1, 4)
          left_state = {pos, left_idx}
          left_cost = cost + 1000

          heap =
            if left_cost <= Map.get(best, left_state, :infinity) do
              Heap.push(heap, {left_cost, left_state, path})
            else
              heap
            end

          # Turn right (clockwise)
          right_idx = Integer.mod(dir_idx + 1, 4)
          right_state = {pos, right_idx}
          right_cost = cost + 1000

          heap =
            if right_cost <= Map.get(best, right_state, :infinity) do
              Heap.push(heap, {right_cost, right_state, path})
            else
              heap
            end

          do_dijkstra(heap, grid, goal, best, best_cost, tiles)
      end
    end
  end
end
