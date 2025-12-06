import AOC

aoc 2021, 22 do
  @moduledoc """
  Day 22: Reactor Reboot

  Toggle 3D cuboid regions on/off.
  Part 1: Only consider -50..50 region
  Part 2: Full input (requires efficient cuboid handling)
  """

  @doc """
  Part 1: Count "on" cubes in the -50..50 region.
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.filter(fn {_on, {x1, x2, y1, y2, z1, z2}} ->
      x1 >= -50 and x2 <= 50 and y1 >= -50 and y2 <= 50 and z1 >= -50 and z2 <= 50
    end)
    |> process_steps()
  end

  @doc """
  Part 2: Count all "on" cubes after all operations.
  """
  def p2(input) do
    input
    |> parse()
    |> process_steps()
  end

  # Process steps using inclusion-exclusion principle
  # Track active cuboids with their sign (+1 for on, -1 for off)
  defp process_steps(steps) do
    Enum.reduce(steps, [], fn {on, cuboid}, active ->
      # For each existing active cuboid, check for intersection
      intersections =
        Enum.flat_map(active, fn {sign, existing} ->
          case intersect(cuboid, existing) do
            nil -> []
            inter -> [{-sign, inter}]
          end
        end)

      # Add the new cuboid if it's "on"
      new_cuboids =
        if on do
          [{1, cuboid} | intersections]
        else
          intersections
        end

      active ++ new_cuboids
    end)
    |> Enum.map(fn {sign, cuboid} -> sign * volume(cuboid) end)
    |> Enum.sum()
  end

  defp intersect({ax1, ax2, ay1, ay2, az1, az2}, {bx1, bx2, by1, by2, bz1, bz2}) do
    x1 = max(ax1, bx1)
    x2 = min(ax2, bx2)
    y1 = max(ay1, by1)
    y2 = min(ay2, by2)
    z1 = max(az1, bz1)
    z2 = min(az2, bz2)

    if x1 <= x2 and y1 <= y2 and z1 <= z2 do
      {x1, x2, y1, y2, z1, z2}
    else
      nil
    end
  end

  defp volume({x1, x2, y1, y2, z1, z2}) do
    (x2 - x1 + 1) * (y2 - y1 + 1) * (z2 - z1 + 1)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [state | coords] =
        Regex.run(~r/(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/, line,
          capture: :all_but_first
        )

      [x1, x2, y1, y2, z1, z2] = Enum.map(coords, &String.to_integer/1)
      on = state == "on"
      {on, {x1, x2, y1, y2, z1, z2}}
    end)
  end
end
