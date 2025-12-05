import AOC

aoc 2018, 25 do
  @moduledoc """
  https://adventofcode.com/2018/day/25

  Day 25: Four-Dimensional Adventure - Finding constellations in 4D space
  """

  @doc """
      iex> p1(example_string(0))
      2
  """
  def p1(input) do
    points = parse_input(input)
    count_constellations(points)
  end

  @doc """
      iex> p2(example_string(0))
      "Merry Christmas!"
  """
  def p2(_input) do
    # Day 25 typically has no Part 2
    "Merry Christmas!"
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer(String.trim(&1)))
      |> List.to_tuple()
    end)
  end

  defp count_constellations(points) do
    # Build adjacency list - points within distance 3 of each other
    graph = build_graph(points)

    # Count connected components using DFS
    count_components(graph, MapSet.new(points), 0)
  end

  defp build_graph(points) do
    # For each point, find all points within distance 3
    points
    |> Enum.map(fn point ->
      neighbors = points
        |> Enum.filter(&(manhattan_distance(point, &1) <= 3))
      {point, neighbors}
    end)
    |> Map.new()
  end

  defp manhattan_distance({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) + abs(w1 - w2)
  end

  defp count_components(graph, unvisited, count) do
    if MapSet.size(unvisited) == 0 do
      count
    else
      # Pick any unvisited point and explore its component
      start = unvisited |> MapSet.to_list() |> hd()
      visited = explore_component(graph, [start], MapSet.new([start]))

      # Remove visited points and continue
      remaining = MapSet.difference(unvisited, visited)
      count_components(graph, remaining, count + 1)
    end
  end

  defp explore_component(_graph, [], visited), do: visited

  defp explore_component(graph, [current | rest], visited) do
    neighbors = Map.get(graph, current, [])

    new_neighbors = neighbors
      |> Enum.reject(&MapSet.member?(visited, &1))

    new_visited = Enum.reduce(new_neighbors, visited, &MapSet.put(&2, &1))
    new_stack = new_neighbors ++ rest

    explore_component(graph, new_stack, new_visited)
  end
end
