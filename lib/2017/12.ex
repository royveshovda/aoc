import AOC

aoc 2017, 12 do
  @moduledoc """
  https://adventofcode.com/2017/day/12
  """

  def p1(input) do
    graph = parse(input)
    find_group(graph, 0) |> MapSet.size()
  end

  def p2(input) do
    graph = parse(input)
    count_groups(graph)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [node, neighbors] = String.split(line, " <-> ")
      node = String.to_integer(node)
      neighbors = neighbors |> String.split(", ") |> Enum.map(&String.to_integer/1)
      {node, neighbors}
    end)
  end

  defp find_group(graph, start) do
    dfs(graph, [start], MapSet.new([start]))
  end

  defp dfs(_graph, [], visited), do: visited
  defp dfs(graph, [node | rest], visited) do
    neighbors = Map.get(graph, node, [])
    new_neighbors = Enum.reject(neighbors, &MapSet.member?(visited, &1))
    new_visited = Enum.reduce(new_neighbors, visited, &MapSet.put(&2, &1))
    dfs(graph, new_neighbors ++ rest, new_visited)
  end

  defp count_groups(graph) do
    nodes = Map.keys(graph)
    count_groups(graph, nodes, MapSet.new(), 0)
  end

  defp count_groups(_graph, [], _visited, count), do: count
  defp count_groups(graph, [node | rest], visited, count) do
    if MapSet.member?(visited, node) do
      count_groups(graph, rest, visited, count)
    else
      group = find_group(graph, node)
      count_groups(graph, rest, MapSet.union(visited, group), count + 1)
    end
  end
end
