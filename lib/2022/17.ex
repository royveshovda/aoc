import AOC

aoc 2022, 17 do
  @moduledoc """
  Day 17: Pyroclastic Flow

  Tetris-like rocks falling with jet pushes.
  Part 1: Tower height after 2022 rocks.
  Part 2: Tower height after 1 trillion rocks (cycle detection).
  """

  # Rock shapes relative to bottom-left corner
  @rocks [
    # horizontal line ####
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    # plus shape
    [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}],
    # J shape (mirrored L)
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    # vertical line
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    # square
    [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  ]

  @doc """
  Part 1: Tower height after 2022 rocks.

  ## Examples

      iex> example = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
      iex> p1(example)
      3068

  """
  def p1(input) do
    jets = parse(input)
    simulate(jets, 2022)
  end

  @doc """
  Part 2: Tower height after 1 trillion rocks.

  ## Examples

      iex> example = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
      iex> p2(example)
      1514285714288

  """
  def p2(input) do
    jets = parse(input)
    simulate_with_cycle(jets, 1_000_000_000_000)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn
      "<" -> -1
      ">" -> 1
    end)
    |> :array.from_list()
  end

  defp simulate(jets, num_rocks) do
    jets_len = :array.size(jets)
    rocks = :array.from_list(@rocks)
    rocks_len = :array.size(rocks)

    {height, _tower, _jet_idx} =
      Enum.reduce(0..(num_rocks - 1), {0, MapSet.new(), 0}, fn rock_idx, {height, tower, jet_idx} ->
        rock = :array.get(rem(rock_idx, rocks_len), rocks)
        # Rock appears: left edge 2 from left wall, bottom edge 3 above highest rock
        drop_rock(rock, 2, height + 3, height, tower, jets, jet_idx, jets_len)
      end)

    height
  end

  defp simulate_with_cycle(jets, target_rocks) do
    jets_len = :array.size(jets)
    rocks = :array.from_list(@rocks)
    rocks_len = :array.size(rocks)

    find_cycle(rocks, rocks_len, jets, jets_len, target_rocks)
  end

  defp find_cycle(rocks, rocks_len, jets, jets_len, target_rocks) do
    initial_state = {0, MapSet.new(), 0}  # height, tower, jet_idx
    cache = %{}

    {final_height, _} =
      Enum.reduce_while(0..(target_rocks - 1), {initial_state, cache}, fn rock_idx, {{height, tower, jet_idx}, cache} ->
        rock = :array.get(rem(rock_idx, rocks_len), rocks)
        {new_height, new_tower, new_jet_idx} = drop_rock(rock, 2, height + 3, height, tower, jets, jet_idx, jets_len)

        # State key: rock type, jet index, top of tower pattern
        state_key = {rem(rock_idx, rocks_len), new_jet_idx, top_pattern(new_tower, new_height)}

        case Map.get(cache, state_key) do
          nil ->
            new_cache = Map.put(cache, state_key, {rock_idx, new_height})
            {:cont, {{new_height, new_tower, new_jet_idx}, new_cache}}

          {prev_rock_idx, prev_height} ->
            # Found cycle!
            cycle_len = rock_idx - prev_rock_idx
            height_per_cycle = new_height - prev_height

            remaining = target_rocks - rock_idx - 1
            full_cycles = div(remaining, cycle_len)
            leftover = rem(remaining, cycle_len)

            # Simulate the leftover rocks
            final_height = new_height + full_cycles * height_per_cycle

            {final_h, _, _} =
              Enum.reduce(0..(leftover - 1), {new_height, new_tower, new_jet_idx}, fn i, {h, t, j} ->
                r = :array.get(rem(rock_idx + 1 + i, rocks_len), rocks)
                drop_rock(r, 2, h + 3, h, t, jets, j, jets_len)
              end)

            extra_height = final_h - new_height
            {:halt, {final_height + extra_height, nil}}
        end
      end)

    final_height
  end

  defp top_pattern(tower, height) do
    # Get relative heights of top of each column (how far below top)
    for x <- 0..6 do
      col_height =
        Enum.reduce_while((height - 1)..0//-1, 0, fn y, _acc ->
          if MapSet.member?(tower, {x, y}), do: {:halt, y}, else: {:cont, 0}
        end)
      height - col_height
    end
  end

  defp drop_rock(rock, x, y, current_height, tower, jets, jet_idx, jets_len) do
    # Apply jet push
    jet = :array.get(jet_idx, jets)
    new_jet_idx = rem(jet_idx + 1, jets_len)

    new_x = if can_move?(rock, x + jet, y, tower), do: x + jet, else: x

    # Try to move down
    if can_move?(rock, new_x, y - 1, tower) do
      drop_rock(rock, new_x, y - 1, current_height, tower, jets, new_jet_idx, jets_len)
    else
      # Come to rest
      {new_tower, max_y} = place_rock(rock, new_x, y, tower)
      new_height = max(max_y + 1, current_height)
      {new_height, new_tower, new_jet_idx}
    end
  end

  defp can_move?(rock, x, y, tower) do
    Enum.all?(rock, fn {dx, dy} ->
      px = x + dx
      py = y + dy
      px >= 0 and px < 7 and py >= 0 and not MapSet.member?(tower, {px, py})
    end)
  end

  defp place_rock(rock, x, y, tower) do
    Enum.reduce(rock, {tower, 0}, fn {dx, dy}, {t, max_y} ->
      px = x + dx
      py = y + dy
      {MapSet.put(t, {px, py}), max(max_y, py)}
    end)
  end
end
