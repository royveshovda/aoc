import AOC

aoc 2021, 15 do
  @moduledoc """
  Day 15: Chiton

  Find lowest-risk path through cave using Dijkstra's algorithm.
  Part 1: Given grid
  Part 2: Grid is 5x5 tiles with increasing risk
  """

  @doc """
  Part 1: Find lowest total risk path from top-left to bottom-right.

  ## Examples

      iex> p1("1163751742\\n1381373672\\n2136511328\\n3694931569\\n7463417111\\n1319128137\\n1359912421\\n3125421639\\n1293138521\\n2311944581")
      40
  """
  def p1(input) do
    grid = parse(input)
    dijkstra(grid)
  end

  @doc """
  Part 2: Grid is tiled 5x5, with risk increasing per tile (wrapping 9->1).

  ## Examples

      iex> p2("1163751742\\n1381373672\\n2136511328\\n3694931569\\n7463417111\\n1319128137\\n1359912421\\n3125421639\\n1293138521\\n2311944581")
      315
  """
  def p2(input) do
    grid = parse(input)
    expanded = expand_grid(grid)
    dijkstra(expanded)
  end

  defp dijkstra(grid) do
    {max_x, max_y} = grid |> Map.keys() |> Enum.max()
    target = {max_x, max_y}

    # Priority queue: {risk, position}
    heap = Heap.new(fn {a, _}, {b, _} -> a < b end)
    heap = Heap.push(heap, {0, {0, 0}})

    dijkstra_loop(heap, MapSet.new(), grid, target)
  end

  defp dijkstra_loop(heap, visited, grid, target) do
    {{risk, pos}, heap} = {Heap.root(heap), Heap.pop(heap)}

    cond do
      pos == target ->
        risk

      MapSet.member?(visited, pos) ->
        dijkstra_loop(heap, visited, grid, target)

      true ->
        visited = MapSet.put(visited, pos)
        {x, y} = pos

        neighbors =
          [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
          |> Enum.filter(&Map.has_key?(grid, &1))
          |> Enum.reject(&MapSet.member?(visited, &1))

        heap =
          Enum.reduce(neighbors, heap, fn neighbor, h ->
            new_risk = risk + Map.get(grid, neighbor)
            Heap.push(h, {new_risk, neighbor})
          end)

        dijkstra_loop(heap, visited, grid, target)
    end
  end

  defp expand_grid(grid) do
    {max_x, max_y} = grid |> Map.keys() |> Enum.max()
    width = max_x + 1
    height = max_y + 1

    for tile_x <- 0..4, tile_y <- 0..4, {pos, risk} <- grid, into: %{} do
      {x, y} = pos
      new_x = x + tile_x * width
      new_y = y + tile_y * height
      new_risk = rem(risk - 1 + tile_x + tile_y, 9) + 1
      {{new_x, new_y}, new_risk}
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
      |> Enum.map(fn {char, x} -> {{x, y}, String.to_integer(char)} end)
    end)
    |> Map.new()
  end
end
