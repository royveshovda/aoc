import AOC

aoc 2021, 12 do
  @moduledoc """
  Day 12: Passage Pathing

  Count paths through cave system.
  Small caves (lowercase) can be visited once (Part 1) or one can be visited twice (Part 2).
  """

  @doc """
  Part 1: Count paths where small caves are visited at most once.

  ## Examples

      iex> p1("start-A\\nstart-b\\nA-c\\nA-b\\nb-d\\nA-end\\nb-end")
      10

      iex> p1("dc-end\\nHN-start\\nstart-kj\\ndc-start\\ndc-HN\\nLN-dc\\nHN-end\\nkj-sa\\nkj-HN\\nkj-dc")
      19
  """
  def p1(input) do
    graph = parse(input)
    count_paths(graph, "start", MapSet.new(["start"]), false)
  end

  @doc """
  Part 2: Count paths where one small cave can be visited twice.

  ## Examples

      iex> p2("start-A\\nstart-b\\nA-c\\nA-b\\nb-d\\nA-end\\nb-end")
      36

      iex> p2("dc-end\\nHN-start\\nstart-kj\\ndc-start\\ndc-HN\\nLN-dc\\nHN-end\\nkj-sa\\nkj-HN\\nkj-dc")
      103
  """
  def p2(input) do
    graph = parse(input)
    count_paths(graph, "start", MapSet.new(["start"]), true)
  end

  defp count_paths(_graph, "end", _visited, _can_revisit), do: 1

  defp count_paths(graph, current, visited, can_revisit) do
    neighbors = Map.get(graph, current, [])

    Enum.reduce(neighbors, 0, fn neighbor, acc ->
      cond do
        neighbor == "start" ->
          acc

        not small_cave?(neighbor) ->
          # Large cave, always can visit
          acc + count_paths(graph, neighbor, visited, can_revisit)

        not MapSet.member?(visited, neighbor) ->
          # Small cave, not visited yet
          new_visited = MapSet.put(visited, neighbor)
          acc + count_paths(graph, neighbor, new_visited, can_revisit)

        can_revisit ->
          # Small cave, visited but we can use our one revisit
          acc + count_paths(graph, neighbor, visited, false)

        true ->
          # Small cave, visited and can't revisit
          acc
      end
    end)
  end

  defp small_cave?(name), do: name == String.downcase(name)

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, graph ->
      [a, b] = String.split(line, "-")

      graph
      |> Map.update(a, [b], &[b | &1])
      |> Map.update(b, [a], &[a | &1])
    end)
  end
end
