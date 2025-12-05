import AOC

aoc 2023, 23 do
  @moduledoc """
  https://adventofcode.com/2023/day/23

  Longest path through hiking trails. Part 2 ignores slopes.
  Uses graph compression for performance.
  """

  @doc """
      iex> p1(example_string())
      94

      iex> p1(input_string())
      2218
  """
  def p1(input) do
    {grid, start, target} = parse(input)
    longest_path(grid, start, target, true)
  end

  @doc """
      iex> p2(example_string())
      154

      iex> p2(input_string())
      6674
  """
  def p2(input) do
    {grid, start, target} = parse(input)
    longest_path(grid, start, target, false)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reject(fn {char, _} -> char == "#" end)
        |> Enum.map(fn {char, c} -> {{r, c}, char} end)
      end)
      |> Map.new()

    start = {0, 1}
    target_row = length(lines) - 1
    target = Enum.find(Map.keys(grid), fn {r, _c} -> r == target_row end)

    {grid, start, target}
  end

  defp longest_path(grid, start, target, respect_slopes) do
    # Compress the graph to just junction nodes
    junctions = find_junctions(grid, start, target)
    compressed = compress_graph(grid, junctions, respect_slopes)

    # DFS for longest path
    dfs_longest(compressed, start, target, MapSet.new([start]), 0)
  end

  defp find_junctions(grid, start, target) do
    # Junctions are nodes with more than 2 connections (plus start/end)
    grid
    |> Map.keys()
    |> Enum.filter(fn pos ->
      pos == start or pos == target or count_neighbors(grid, pos) > 2
    end)
    |> MapSet.new()
  end

  defp count_neighbors(grid, {r, c}) do
    [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
    |> Enum.count(&Map.has_key?(grid, &1))
  end

  defp compress_graph(grid, junctions, respect_slopes) do
    # For each junction, find direct distances to other junctions
    Enum.reduce(junctions, %{}, fn junction, graph ->
      edges = find_edges_from(grid, junctions, junction, respect_slopes)
      Map.put(graph, junction, edges)
    end)
  end

  defp find_edges_from(grid, junctions, start, respect_slopes) do
    # BFS from start to find all reachable junctions
    neighbors(grid, start, respect_slopes)
    |> Enum.flat_map(fn next ->
      walk_to_junction(grid, junctions, next, start, 1, respect_slopes)
    end)
    |> Enum.filter(fn {pos, _dist} -> pos != start end)
  end

  defp walk_to_junction(grid, junctions, pos, prev, dist, respect_slopes) do
    if MapSet.member?(junctions, pos) do
      [{pos, dist}]
    else
      neighbors(grid, pos, respect_slopes)
      |> Enum.reject(&(&1 == prev))
      |> Enum.flat_map(fn next ->
        walk_to_junction(grid, junctions, next, pos, dist + 1, respect_slopes)
      end)
    end
  end

  defp neighbors(grid, {r, c}, respect_slopes) do
    dirs = [{r - 1, c, "^"}, {r + 1, c, "v"}, {r, c - 1, "<"}, {r, c + 1, ">"}]

    current = Map.get(grid, {r, c})

    dirs
    |> Enum.filter(fn {nr, nc, slope} ->
      Map.has_key?(grid, {nr, nc}) and
        (not respect_slopes or current == "." or current == slope)
    end)
    |> Enum.map(fn {nr, nc, _} -> {nr, nc} end)
  end

  defp dfs_longest(graph, current, target, visited, dist) do
    if current == target do
      dist
    else
      Map.get(graph, current, [])
      |> Enum.reject(fn {next, _} -> MapSet.member?(visited, next) end)
      |> Enum.map(fn {next, d} ->
        dfs_longest(graph, next, target, MapSet.put(visited, next), dist + d)
      end)
      |> Enum.max(fn -> 0 end)
    end
  end
end
