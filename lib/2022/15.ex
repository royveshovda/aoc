import AOC

aoc 2022, 15 do
  @moduledoc """
  Day 15: Beacon Exclusion Zone

  Sensors with Manhattan distance to closest beacon.
  Part 1: Count positions on row y=2000000 that can't contain beacon.
  Part 2: Find tuning frequency of distress beacon (x*4000000+y).

  Optimization: For P2, check along sensor diamond boundaries instead of
  scanning all 4M rows. The beacon must be at distance+1 from some sensor.
  """

  @doc """
  Part 1: Positions on y=2000000 that cannot contain a beacon.
  """
  def p1(input, target_y \\ 2_000_000) do
    sensors = parse(input)

    # Get ranges covered on target row
    ranges =
      sensors
      |> Enum.map(fn {sx, sy, dist, _bx, _by} -> coverage_at_y(sx, sy, dist, target_y) end)
      |> Enum.reject(&is_nil/1)
      |> merge_ranges()

    # Count total positions minus beacons on that row
    beacons_on_row =
      sensors
      |> Enum.map(fn {_sx, _sy, _dist, bx, by} -> {bx, by} end)
      |> Enum.filter(fn {_bx, by} -> by == target_y end)
      |> Enum.uniq()
      |> length()

    total = Enum.reduce(ranges, 0, fn {a, b}, acc -> acc + b - a + 1 end)
    total - beacons_on_row
  end

  @doc """
  Part 2: Tuning frequency of distress beacon (x*4000000+y).
  """
  def p2(input, max_coord \\ 4_000_000) do
    sensors = parse(input)
    sensors_simple = Enum.map(sensors, fn {sx, sy, dist, _bx, _by} -> {sx, sy, dist} end)

    # The beacon must be just outside exactly one sensor's range
    # Check all points at distance+1 from each sensor boundary
    {x, y} = find_beacon_fast(sensors_simple, max_coord)
    x * 4_000_000 + y
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [sx, sy, bx, by] =
        Regex.scan(~r/-?\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      dist = abs(sx - bx) + abs(sy - by)
      {sx, sy, dist, bx, by}
    end)
  end

  defp coverage_at_y(sx, sy, dist, target_y) do
    remaining = dist - abs(sy - target_y)
    if remaining >= 0 do
      {sx - remaining, sx + remaining}
    else
      nil
    end
  end

  defp merge_ranges(ranges) do
    ranges
    |> Enum.sort()
    |> Enum.reduce([], fn
      range, [] -> [range]
      {a2, b2}, [{a1, b1} | rest] ->
        if a2 <= b1 + 1 do
          [{a1, max(b1, b2)} | rest]
        else
          [{a2, b2}, {a1, b1} | rest]
        end
    end)
    |> Enum.reverse()
  end

  # Fast approach: check points along sensor boundaries
  defp find_beacon_fast(sensors, max_coord) do
    # Generate candidate points: just outside each sensor's diamond
    sensors
    |> Enum.find_value(fn {sx, sy, dist} ->
      boundary_dist = dist + 1

      # Walk around the diamond boundary
      Enum.find_value(0..boundary_dist, fn d ->
        # Check all 4 sides of the diamond
        candidates = [
          {sx + d, sy + (boundary_dist - d)},       # top-right edge
          {sx + d, sy - (boundary_dist - d)},       # bottom-right edge
          {sx - d, sy + (boundary_dist - d)},       # top-left edge
          {sx - d, sy - (boundary_dist - d)}        # bottom-left edge
        ]
        |> Enum.filter(fn {x, y} -> x >= 0 and x <= max_coord and y >= 0 and y <= max_coord end)
        |> Enum.uniq()

        Enum.find(candidates, fn {x, y} ->
          not_covered?(x, y, sensors)
        end)
      end)
    end)
  end

  defp not_covered?(x, y, sensors) do
    Enum.all?(sensors, fn {sx, sy, dist} ->
      abs(x - sx) + abs(y - sy) > dist
    end)
  end
end
