import AOC

aoc 2023, 25 do
  @moduledoc """
  https://adventofcode.com/2023/day/25
  """

  @doc """
      iex> p1(example_string())
      54

      iex> p1(input_string())
      544523
  """
  def p1(input) do
    connections =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn line, map ->
        [_, name, connected_components_str, _] = Regex.run(~r"^([a-z]+)\:(( +[a-z]+)+)\n?$", line)
        connected_components = String.split(connected_components_str)
        Enum.reduce(connected_components, Map.put(map, name, connected_components ++ Map.get(map, name, [])), fn connected_component, acc ->
          Map.put(acc, connected_component, [name | Map.get(acc, connected_component, [])])
        end)
      end)

    find_solution(connections)
  end

  @doc """
      #iex> p2(example_string())
  """
  def p2(input) do
    input
  end

  def new_links(connections, cluster, new_component, previous_links) do
    (
      previous_links
      |> Enum.reject(&(&1 == new_component))
    ) ++ (
      Map.get(connections, new_component, [])
      |> Enum.filter(fn connection -> not(connection in cluster) end)
    )
  end

  def grow_cluster(_, _, []), do: nil
  def grow_cluster(connections, cluster, links) when length(links) == 3, do: (length(Map.keys(connections)) - length(cluster)) * length(cluster)
  def grow_cluster(connections, cluster, links) do
    links
    |> Enum.frequencies()
    |> Map.to_list()
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
    |> Enum.reduce_while(nil, fn {name, _ }, _ ->
      case grow_cluster(connections, [name | cluster], new_links(connections, cluster, name, links)) do
        nil -> {:cont, nil}
        res -> {:halt, res}
      end
    end)
  end

  def find_solution(connections) do
    initial_component = connections
    |> Map.keys()
    |> Enum.random()

    case grow_cluster(connections, [initial_component], Map.get(connections, initial_component, [])) do
      nil -> find_solution(connections)
      val -> val
    end
  end
end
