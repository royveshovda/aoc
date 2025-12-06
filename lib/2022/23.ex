import AOC

aoc 2022, 23 do
  @moduledoc """
  Day 23: Unstable Diffusion

  Elves move in grid following proposal rules.
  Part 1: Empty ground in bounding box after 10 rounds.
  Part 2: First round where no elf moves.
  """

  @north {-1, 0}
  @south {1, 0}
  @east {0, 1}
  @west {0, -1}
  @ne {-1, 1}
  @nw {-1, -1}
  @se {1, 1}
  @sw {1, -1}

  @northern {@north, [@north, @ne, @nw]}
  @southern {@south, [@south, @se, @sw]}
  @western {@west, [@west, @nw, @sw]}
  @eastern {@east, [@east, @ne, @se]}

  @doc """
  Part 1: Empty ground tiles after 10 rounds.

  ## Examples

      iex> example = \"\"\"
      ...> ....#..
      ...> ..###.#
      ...> #...#.#
      ...> .#...##
      ...> #.###..
      ...> ##.#.##
      ...> .#..#..
      ...> \"\"\"
      iex> Y2022.D23.p1(example)
      110
  """
  def p1(input) do
    elves = parse(input)
    prefs_base = [@northern, @southern, @western, @eastern]

    elves =
      Enum.reduce(1..10, elves, fn round, acc ->
        run_round(acc, round_prefs(round, prefs_base))
      end)

    bounding_area(elves) - MapSet.size(elves)
  end

  @doc """
  Part 2: First round where no elf moves.

  ## Examples

      iex> example = \"\"\"
      ...> ....#..
      ...> ..###.#
      ...> #...#.#
      ...> .#...##
      ...> #.###..
      ...> ##.#.##
      ...> .#..#..
      ...> \"\"\"
      iex> Y2022.D23.p2(example)
      20
  """
  def p2(input) do
    elves = parse(input)
    prefs_base = [@northern, @southern, @western, @eastern]
    find_stable_round(elves, prefs_base, 1)
  end

  defp find_stable_round(elves, prefs_base, round) do
    prefs = round_prefs(round, prefs_base)
    case run_round_fast(elves, prefs) do
      :stable -> round
      next -> find_stable_round(next, prefs_base, round + 1)
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.to_charlist()
      |> Enum.with_index(1)
      |> Enum.filter(fn {c, _} -> c == ?# end)
      |> Enum.map(fn {_, col} -> {row, col} end)
    end)
    |> MapSet.new()
  end

  defp round_prefs(round, prefs) do
    offset = rem(round - 1, 4)
    Enum.slice(prefs, offset, 4) ++ Enum.slice(prefs, 0, offset)
  end

  defp run_round(elves, prefs) do
    proposals =
      elves
      |> Enum.map(fn elf -> {elf, pick_move(elf, elves, prefs)} end)
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

    proposals
    |> Enum.flat_map(fn
      {dest, [_single]} -> [dest]
      {_dest, many} -> many
    end)
    |> MapSet.new()
  end

  # Optimized version that returns :stable if no moves happened
  defp run_round_fast(elves, prefs) do
    # Only consider elves with neighbors
    {active, passive} = Enum.split_with(elves, fn elf -> has_neighbors?(elf, elves) end)

    if active == [] do
      :stable
    else
      proposals =
        active
        |> Enum.map(fn elf -> {elf, pick_active_move(elf, elves, prefs)} end)
        |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

      # Check if any elf actually moved
      any_moved = Enum.any?(proposals, fn
        {dest, [single]} -> dest != single
        _ -> false
      end)

      if any_moved do
        moved =
          proposals
          |> Enum.flat_map(fn
            {dest, [_single]} -> [dest]
            {_dest, many} -> many
          end)
          |> MapSet.new()

        MapSet.union(moved, MapSet.new(passive))
      else
        :stable
      end
    end
  end

  defp pick_move(elf, elves, prefs) do
    if no_neighbors?(elf, elves) do
      elf
    else
      pick_active_move(elf, elves, prefs)
    end
  end

  defp pick_active_move(elf, elves, prefs) do
    case Enum.find(prefs, fn {_, check_dirs} ->
           Enum.all?(check_dirs, fn dir -> not MapSet.member?(elves, move(elf, dir)) end)
         end) do
      {move_dir, _} -> move(elf, move_dir)
      nil -> elf
    end
  end

  defp has_neighbors?({row, col}, elves) do
    MapSet.member?(elves, {row - 1, col - 1}) or
    MapSet.member?(elves, {row - 1, col}) or
    MapSet.member?(elves, {row - 1, col + 1}) or
    MapSet.member?(elves, {row, col + 1}) or
    MapSet.member?(elves, {row + 1, col + 1}) or
    MapSet.member?(elves, {row + 1, col}) or
    MapSet.member?(elves, {row + 1, col - 1}) or
    MapSet.member?(elves, {row, col - 1})
  end

  defp no_neighbors?(elf, elves), do: not has_neighbors?(elf, elves)

  defp move({row, col}, {dr, dc}), do: {row + dr, col + dc}

  defp bounding_area(elves) do
    {min_row, max_row} = elves |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_col, max_col} = elves |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    (max_row - min_row + 1) * (max_col - min_col + 1)
  end
end
