import AOC

aoc 2016, 24 do
  @moduledoc """
  https://adventofcode.com/2016/day/24
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    {grid, locations} = parse(input)
    distances = build_distance_matrix(grid, locations)

    # Find shortest path visiting all locations starting from 0
    other_locations = Map.keys(locations) |> Enum.reject(&(&1 == 0))

    other_locations
    |> permutations()
    |> Enum.map(fn path ->
      full_path = [0 | path]
      path_distance(full_path, distances)
    end)
    |> Enum.min()
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    {grid, locations} = parse(input)
    distances = build_distance_matrix(grid, locations)

    # Find shortest path visiting all locations starting from 0 and returning to 0
    other_locations = Map.keys(locations) |> Enum.reject(&(&1 == 0))

    other_locations
    |> permutations()
    |> Enum.map(fn path ->
      full_path = [0 | path] ++ [0]
      path_distance(full_path, distances)
    end)
    |> Enum.min()
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    grid = for {line, y} <- Enum.with_index(lines),
               {char, x} <- Enum.with_index(String.graphemes(line)),
               char != "#",
               into: %{} do
      {{x, y}, char}
    end

    locations = grid
                |> Enum.filter(fn {_pos, char} -> char =~ ~r/\d/ end)
                |> Enum.map(fn {pos, char} -> {String.to_integer(char), pos} end)
                |> Map.new()

    {grid, locations}
  end

  defp build_distance_matrix(grid, locations) do
    for {num1, pos1} <- locations, {num2, pos2} <- locations, num1 < num2 do
      distance = bfs(grid, pos1, pos2)
      [{{num1, num2}, distance}, {{num2, num1}, distance}]
    end
    |> List.flatten()
    |> Map.new()
  end

  defp bfs(grid, start, goal) do
    queue = :queue.from_list([{start, 0}])
    visited = MapSet.new([start])
    bfs_loop(grid, queue, visited, goal)
  end

  defp bfs_loop(grid, queue, visited, goal) do
    case :queue.out(queue) do
      {{:value, {pos, dist}}, queue} ->
        if pos == goal do
          dist
        else
          neighbors = get_neighbors(pos)
                     |> Enum.filter(&Map.has_key?(grid, &1))
                     |> Enum.reject(&MapSet.member?(visited, &1))

          new_queue = Enum.reduce(neighbors, queue, fn n, q -> :queue.in({n, dist + 1}, q) end)
          new_visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))

          bfs_loop(grid, new_queue, new_visited, goal)
        end
      {:empty, _} -> :infinity
    end
  end

  defp get_neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp path_distance(path, distances) do
    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> Map.get(distances, {a, b}, 0) end)
    |> Enum.sum()
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end
end
