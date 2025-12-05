import AOC

aoc 2023, 22 do
  @moduledoc """
  https://adventofcode.com/2023/day/22

  Sand slabs falling and stacking.
  Optimized approach: simulate fall once, then for each brick removal
  re-simulate to count what falls.
  """

  @doc """
      iex> p1(example_string())
      5

      iex> p1(input_string())
      437
  """
  def p1(input) do
    bricks = parse(input)
    {_, settled} = fall(bricks)

    # For each brick, check if removing it causes any others to fall
    settled
    |> Enum.count(fn brick ->
      others = List.delete(settled, brick)
      {fallen_count, _} = fall(others)
      fallen_count == 0
    end)
  end

  @doc """
      iex> p2(example_string())
      7

      iex> p2(input_string())
      42561
  """
  def p2(input) do
    bricks = parse(input)
    {_, settled} = fall(bricks)

    # Sum how many bricks would fall for each removal
    settled
    |> Enum.map(fn brick ->
      others = List.delete(settled, brick)
      {fallen_count, _} = fall(others)
      fallen_count
    end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_brick/1)
    |> sort_by_z()
  end

  defp parse_brick(line) do
    [xs, ys, zs, xe, ye, ze] =
      Regex.run(~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    # Generate all cubes for this brick
    for x <- min(xs, xe)..max(xs, xe),
        y <- min(ys, ye)..max(ys, ye),
        z <- min(zs, ze)..max(zs, ze),
        do: {x, y, z}
  end

  defp sort_by_z(bricks) do
    Enum.sort_by(bricks, fn brick ->
      brick |> Enum.map(&elem(&1, 2)) |> Enum.min()
    end)
  end

  defp fall(bricks, z_levels \\ %{}, fallen \\ [], num_fallen \\ 0)

  defp fall([], _, fallen, num_fallen), do: {num_fallen, sort_by_z(fallen)}

  defp fall([brick | rest], z_levels, fallen, num_fallen) do
    # Find how far this brick can fall
    fall_distance =
      brick
      |> bottom_cubes()
      |> Enum.map(fn {x, y, z} ->
        z - Map.get(z_levels, {x, y}, 0) - 1
      end)
      |> Enum.min()

    # Track if this brick actually fell
    did_fall = if fall_distance > 0, do: 1, else: 0

    # Move brick down
    new_brick = Enum.map(brick, fn {x, y, z} -> {x, y, z - fall_distance} end)

    # Update z_levels with new brick positions
    new_z_levels =
      Enum.reduce(new_brick, z_levels, fn {x, y, z}, levels ->
        Map.put(levels, {x, y}, z)
      end)

    fall(rest, new_z_levels, [new_brick | fallen], num_fallen + did_fall)
  end

  # Get the bottom layer cubes of a brick
  defp bottom_cubes(brick) do
    min_z = brick |> Enum.map(&elem(&1, 2)) |> Enum.min()
    Enum.filter(brick, fn {_, _, z} -> z == min_z end)
  end
end
