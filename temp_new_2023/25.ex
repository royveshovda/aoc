import AOC

aoc 2023, 25 do
  @moduledoc """
  https://adventofcode.com/2023/day/25

  Find 3 wires to cut that splits graph into two components.
  Product of component sizes.
  """

  @doc """
      iex> p1(example_string())
      54

      iex> p1(input_string())
      544523
  """
  def p1(input) do
    graph = parse(input)

    # Find the 3 edges to cut using edge frequency heuristic
    # Run BFS from multiple random nodes, edges on shortest paths
    # between distant nodes are likely to be cut edges

    # Get all nodes and edges
    nodes = Map.keys(graph)

    # Sample random node pairs and count edge usage in shortest paths
    edge_counts = count_edge_usage(graph, nodes, 500)

    # Find top 3 most used edges (these are likely the bridges)
    top_edges = edge_counts
                |> Enum.sort_by(fn {_e, count} -> -count end)
                |> Enum.take(10)
                |> Enum.map(&elem(&1, 0))

    # Try combinations of 3 edges from top candidates
    find_valid_cut(graph, nodes, top_edges)
  end

  @doc """
  No part 2 for Day 25 - it's the final day!
  """
  def p2(_input) do
    "Merry Christmas!"
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      [from, rest] = String.split(line, ": ")
      tos = String.split(rest, " ")

      acc = Map.update(acc, from, MapSet.new(tos), &MapSet.union(&1, MapSet.new(tos)))
      Enum.reduce(tos, acc, fn to, a ->
        Map.update(a, to, MapSet.new([from]), &MapSet.put(&1, from))
      end)
    end)
  end

  defp count_edge_usage(graph, nodes, samples) do
    # Pick random pairs and count edge usage in BFS paths
    :rand.seed(:exsss, {42, 42, 42})

    1..samples
    |> Enum.reduce(%{}, fn _, acc ->
      start = Enum.random(nodes)
      target = Enum.random(nodes)

      if start != target do
        case bfs_path(graph, start, target) do
          nil -> acc
          path -> count_path_edges(path, acc)
        end
      else
        acc
      end
    end)
  end

  defp bfs_path(graph, start, target) do
    queue = :queue.from_list([{start, [start]}])
    visited = MapSet.new([start])
    do_bfs_path(graph, queue, visited, target)
  end

  defp do_bfs_path(_graph, {[], []}, _visited, _target), do: nil
  defp do_bfs_path(graph, queue, visited, target) do
    {{:value, {current, path}}, queue} = :queue.out(queue)

    if current == target do
      path
    else
      neighbors = Map.get(graph, current, MapSet.new()) |> MapSet.difference(visited)

      {queue, visited} = Enum.reduce(neighbors, {queue, visited}, fn n, {q, v} ->
        {:queue.in({n, path ++ [n]}, q), MapSet.put(v, n)}
      end)

      do_bfs_path(graph, queue, visited, target)
    end
  end

  defp count_path_edges([_], acc), do: acc
  defp count_path_edges([a, b | rest], acc) do
    edge = edge_key(a, b)
    acc = Map.update(acc, edge, 1, &(&1 + 1))
    count_path_edges([b | rest], acc)
  end

  defp edge_key(a, b), do: if(a < b, do: {a, b}, else: {b, a})

  defp find_valid_cut(graph, nodes, candidate_edges) do
    # Try combinations of 3 edges
    combos = for {e1, i} <- Enum.with_index(candidate_edges),
                 {e2, j} <- Enum.with_index(candidate_edges),
                 {e3, k} <- Enum.with_index(candidate_edges),
                 i < j and j < k,
                 do: [e1, e2, e3]

    Enum.find_value(combos, fn edges_to_cut ->
      modified = remove_edges(graph, edges_to_cut)
      {comp1, comp2} = find_components(modified, hd(nodes))

      if comp2 > 0 and comp1 + comp2 == length(nodes) do
        comp1 * comp2
      end
    end)
  end

  defp remove_edges(graph, edges) do
    Enum.reduce(edges, graph, fn {a, b}, g ->
      g
      |> Map.update!(a, &MapSet.delete(&1, b))
      |> Map.update!(b, &MapSet.delete(&1, a))
    end)
  end

  defp find_components(graph, start) do
    # BFS to find component containing start
    comp1 = bfs_component(graph, start)
    comp1_size = MapSet.size(comp1)
    total = map_size(graph)
    {comp1_size, total - comp1_size}
  end

  defp bfs_component(graph, start) do
    queue = :queue.from_list([start])
    visited = MapSet.new([start])
    do_bfs_component(graph, queue, visited)
  end

  defp do_bfs_component(_graph, {[], []}, visited), do: visited
  defp do_bfs_component(graph, queue, visited) do
    {{:value, current}, queue} = :queue.out(queue)

    neighbors = Map.get(graph, current, MapSet.new()) |> MapSet.difference(visited)

    {queue, visited} = Enum.reduce(neighbors, {queue, visited}, fn n, {q, v} ->
      {:queue.in(n, q), MapSet.put(v, n)}
    end)

    do_bfs_component(graph, queue, visited)
  end
end
