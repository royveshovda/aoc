import AOC

aoc 2015, 9 do
  @moduledoc """
  https://adventofcode.com/2015/day/9

  Day 9: All in a Single Night
  Traveling Salesman Problem - find shortest/longest route visiting all locations once.
  """

  @doc """
  Part 1: Find the shortest distance visiting all locations exactly once.
  Can start and end at any locations.

  Example:
  - London to Dublin = 464
  - London to Belfast = 518
  - Dublin to Belfast = 141

  Shortest route: London -> Dublin -> Belfast = 605

      iex> p1(example_string(0))
      605
  """
  def p1(input) do
    {distances, locations} = parse_distances(input)

    # Try all permutations and find minimum distance
    locations
    |> permutations()
    |> Enum.map(&calculate_route_distance(&1, distances))
    |> Enum.min()
  end

  @doc """
  Part 2: Find the longest distance visiting all locations exactly once.

      iex> p2(example_string(0))
      982
  """
  def p2(input) do
    {distances, locations} = parse_distances(input)

    # Try all permutations and find maximum distance
    locations
    |> permutations()
    |> Enum.map(&calculate_route_distance(&1, distances))
    |> Enum.max()
  end

  defp parse_distances(input) do
    lines = String.split(input, "\n", trim: true)

    distances =
      lines
      |> Enum.flat_map(fn line ->
        [from_to, distance] = String.split(line, " = ")
        [from, to] = String.split(from_to, " to ")
        dist = String.to_integer(distance)

        # Store both directions since graph is undirected
        [{{from, to}, dist}, {{to, from}, dist}]
      end)
      |> Map.new()

    locations =
      lines
      |> Enum.flat_map(fn line ->
        [from_to, _] = String.split(line, " = ")
        String.split(from_to, " to ")
      end)
      |> Enum.uniq()

    {distances, locations}
  end

  defp calculate_route_distance(route, distances) do
    route
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] -> Map.get(distances, {from, to}) end)
    |> Enum.sum()
  end

  # Generate all permutations of a list
  defp permutations([]), do: [[]]
  defp permutations(list) do
    for elem <- list,
        rest <- permutations(list -- [elem]),
        do: [elem | rest]
  end
end
