import AOC

aoc 2024, 23 do
  @moduledoc """
  https://adventofcode.com/2024/day/23
  """

  def p1(input) do
    adjacency_map = LanParty.read_graph(input)
    triangles = LanParty.triangles(adjacency_map)
    LanParty.count_with_t(triangles)
  end

  def p2(input) do
    graph = read_graph(input)
    max_clique = find_maximum_clique(graph)
    password = generate_lan_party_password(max_clique)
    password
  end

  def read_graph(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      if line == "" do
        acc
      else
        [node_a, node_b] = String.split(line, "-", parts: 2)

        acc
        |> Map.update(node_a, MapSet.new([node_b]), &MapSet.put(&1, node_b))
        |> Map.update(node_b, MapSet.new([node_a]), &MapSet.put(&1, node_a))
      end
    end)
  end

  def bron_kerbosch(r, p, x, graph, cliques) do
    if MapSet.size(p) == 0 and MapSet.size(x) == 0 do
      [r | cliques]
    else
      pivot = pick_any(MapSet.union(p, x))
      non_neighbors = MapSet.difference(p, Map.get(graph, pivot, MapSet.new()))

      Enum.reduce(non_neighbors, cliques, fn v, acc ->
        new_r = MapSet.put(r, v)
        new_p = MapSet.intersection(p, Map.get(graph, v, MapSet.new()))
        new_x = MapSet.intersection(x, Map.get(graph, v, MapSet.new()))
        sub_cliques = bron_kerbosch(new_r, new_p, new_x, graph, acc)
        bron_kerbosch_update(p, x, v)
        sub_cliques
      end)
    end
  end

  defp bron_kerbosch_update(_p, _x, _v) do
    # Remove v from P, add to X (mutating sets in caller's scope if needed)
    :ok
  end

  defp pick_any(set) do
    set
    |> Enum.at(0)
  end

  def find_maximum_clique(graph) do
    nodes = Map.keys(graph) |> MapSet.new()
    all_cliques = bron_kerbosch(MapSet.new(), nodes, MapSet.new(), graph, [])
    Enum.max_by(all_cliques, &MapSet.size/1)
  end

  def generate_lan_party_password(clique) do
    clique
    |> Enum.sort()
    |> Enum.join(",")
  end
end

defmodule LanParty do
  @moduledoc """
  Helper functions for the LAN party problem.

  # Why this is faster
  # 	•	Original approach:
  # You first took all combinations of size 3 from all nodes (i.e. \binom{n}{3} triples), then checked if each triple was a valid triangle. For large n, that’s O(n^3) checks in the worst case.
  # 	•	Improved approach:
  # You iterate over each node a and only look at pairs of neighbors (b, c). If a has d neighbors, you do roughly \binom{d}{2} checks. Summed over all nodes, you often get far fewer checks than \binom{n}{3}, especially if the graph is not extremely dense.
  # 	•	No duplicates:
  # Enforcing a < b < c ensures each triangle is counted exactly once—no need for extra Enum.uniq() or sorting within each triple.

  # Depending on the structure of your graph (especially if it is sparse or only moderately dense), this can provide a significant speedup for large inputs.
  """
  def read_graph(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reduce(%{}, fn line, acc ->
      [node1, node2] = String.split(line, "-")

      acc =
        Map.update(acc, node1, MapSet.new([node2]), &MapSet.put(&1, node2))

      acc =
        Map.update(acc, node2, MapSet.new([node1]), &MapSet.put(&1, node1))

      acc
    end)
  end

  # More efficient triangle enumerator: for each node 'a',
  # check only its neighbor pairs (b, c) to see if they connect.
  def triangles(adj_map) do
    # Sort the nodes so we can impose an ordering: a < b < c
    nodes = Map.keys(adj_map) |> Enum.sort()

    nodes
    |> Enum.flat_map(fn a ->
      neighbors = Map.fetch!(adj_map, a)

      # Only consider neighbors b, c where b > a and c > b
      # If b, c are also connected (i.e. c in adj_map[b]), we have a triangle [a,b,c].
      for b <- neighbors,
          b > a,
          c <- neighbors,
          c > b,
          MapSet.member?(adj_map[b], c) do
        [a, b, c]
      end
    end)
  end

  # Counts how many triangles have at least one node starting with "t"
  def count_with_t(triples) do
    triples
    |> Enum.count(fn triple ->
      Enum.any?(triple, &String.starts_with?(&1, "t"))
    end)
  end
end
