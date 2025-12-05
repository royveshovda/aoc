import AOC

aoc 2018, 18 do
  @moduledoc """
  https://adventofcode.com/2018/day/18

  Day 18: Settlers of The North Pole - Cellular automaton simulation
  """

  @doc """
  Part 1: Calculate resource value after 10 minutes

  ## Examples

      iex> input = ".#.#...|#.\\n.....#|##|\\n.|..|...#.\\n..|#.....#\\n#.#|||#|#|\\n...#.||...\\n.|....|...\\n||...#|.#|\\n|.||||..|.\\n...#.|..|."
      iex> p1(input)
      1147
  """
  def p1(input) do
    grid = parse_grid(input)

    final_grid = simulate(grid, 10)

    calculate_resource_value(final_grid)
  end

  @doc """
  Part 2: Calculate resource value after 1000000000 minutes
  Uses cycle detection to avoid simulating all iterations
  """
  def p2(input) do
    grid = parse_grid(input)

    # Find cycle
    {cycle_start, cycle_length, states} = find_cycle(grid)

    # Calculate which state we'd be at after 1000000000 minutes
    target = 1_000_000_000

    if target < cycle_start do
      # Before cycle starts
      final_grid = simulate(grid, target)
      calculate_resource_value(final_grid)
    else
      # Within the cycle
      offset = rem(target - cycle_start, cycle_length)
      final_grid = Enum.at(states, cycle_start + offset)
      calculate_resource_value(final_grid)
    end
  end

  defp parse_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
    end)
    |> Map.new()
  end

  defp simulate(grid, minutes) do
    Enum.reduce(1..minutes, grid, fn _minute, current_grid ->
      step(current_grid)
    end)
  end

  defp step(grid) do
    grid
    |> Enum.map(fn {pos, cell} ->
      {pos, transform_cell(cell, pos, grid)}
    end)
    |> Map.new()
  end

  defp transform_cell(cell, pos, grid) do
    neighbors = get_neighbors(pos, grid)
    tree_count = Enum.count(neighbors, &(&1 == "|"))
    lumber_count = Enum.count(neighbors, &(&1 == "#"))

    case cell do
      "." ->
        # Open ground becomes trees if 3+ adjacent trees
        if tree_count >= 3, do: "|", else: "."

      "|" ->
        # Trees become lumberyard if 3+ adjacent lumberyards
        if lumber_count >= 3, do: "#", else: "|"

      "#" ->
        # Lumberyard stays if adjacent to at least 1 lumberyard and 1 tree
        if lumber_count >= 1 and tree_count >= 1, do: "#", else: "."
    end
  end

  defp get_neighbors({x, y}, grid) do
    [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]
    |> Enum.map(&Map.get(grid, &1))
    |> Enum.reject(&is_nil/1)
  end

  defp calculate_resource_value(grid) do
    tree_count = grid |> Map.values() |> Enum.count(&(&1 == "|"))
    lumber_count = grid |> Map.values() |> Enum.count(&(&1 == "#"))
    tree_count * lumber_count
  end

  defp find_cycle(initial_grid) do
    # Simulate and track states until we find a repeat
    find_cycle_loop(initial_grid, 0, %{}, [initial_grid])
  end

  defp find_cycle_loop(grid, minute, seen, states) do
    grid_key = grid_to_key(grid)

    case Map.get(seen, grid_key) do
      nil ->
        # Haven't seen this state before, continue
        new_grid = step(grid)
        new_seen = Map.put(seen, grid_key, minute)
        find_cycle_loop(new_grid, minute + 1, new_seen, states ++ [new_grid])

      cycle_start ->
        # Found a cycle!
        cycle_length = minute - cycle_start
        {cycle_start, cycle_length, states}
    end
  end

  defp grid_to_key(grid) do
    grid
    |> Enum.sort()
    |> Enum.map(fn {_pos, cell} -> cell end)
    |> Enum.join()
  end
end
