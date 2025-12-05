import AOC

aoc 2024, 23 do
  @moduledoc """
  https://adventofcode.com/2024/day/23

  LAN Party - Find triangles with 't' nodes and maximum clique.
  """

  def p1(input) do
    graph = parse(input)
    nodes = Map.keys(graph)

    # Find all triangles
    triangles =
      for a <- nodes,
          b <- Map.get(graph, a, MapSet.new()),
          b > a,
          c <- Map.get(graph, b, MapSet.new()),
          c > b,
          MapSet.member?(Map.get(graph, a, MapSet.new()), c) do
        {a, b, c}
      end

    # Count those with at least one 't'-starting node
    triangles
    |> Enum.count(fn {a, b, c} ->
      String.starts_with?(a, "t") or String.starts_with?(b, "t") or String.starts_with?(c, "t")
    end)
  end

  def p2(input) do
    graph = parse(input)

    # Find maximum clique using Bron-Kerbosch
    max_clique = bron_kerbosch(MapSet.new(), MapSet.new(Map.keys(graph)), MapSet.new(), graph)

    max_clique
    |> MapSet.to_list()
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, graph ->
      [a, b] = String.split(line, "-")
      graph
      |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
      |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
    end)
  end

  defp bron_kerbosch(r, p, x, graph) do
    if MapSet.size(p) == 0 and MapSet.size(x) == 0 do
      r
    else
      # Pivot selection: choose vertex with most neighbors in P
      pivot =
        MapSet.union(p, x)
        |> Enum.max_by(fn v -> MapSet.size(MapSet.intersection(p, Map.get(graph, v, MapSet.new()))) end)

      pivot_neighbors = Map.get(graph, pivot, MapSet.new())

      MapSet.difference(p, pivot_neighbors)
      |> Enum.reduce(MapSet.new(), fn v, best ->
        neighbors = Map.get(graph, v, MapSet.new())
        result = bron_kerbosch(
          MapSet.put(r, v),
          MapSet.intersection(p, neighbors),
          MapSet.intersection(x, neighbors),
          graph
        )
        if MapSet.size(result) > MapSet.size(best), do: result, else: best
      end)
    end
  end
end
