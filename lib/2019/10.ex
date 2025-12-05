import AOC

aoc 2019, 10 do
  @moduledoc """
  https://adventofcode.com/2019/day/10
  Monitoring Station - asteroid field line of sight
  """

  def p1(input) do
    asteroids = parse(input)

    asteroids
    |> Enum.map(fn pos -> {pos, count_visible(pos, asteroids)} end)
    |> Enum.max_by(fn {_pos, count} -> count end)
    |> elem(1)
  end

  def p2(input) do
    asteroids = parse(input)

    # Find the best station location
    {station, _count} =
      asteroids
      |> Enum.map(fn pos -> {pos, count_visible(pos, asteroids)} end)
      |> Enum.max_by(fn {_pos, count} -> count end)

    # Get the 200th asteroid to be vaporized
    {x, y} = vaporize_nth(station, asteroids -- [station], 200)
    x * 100 + y
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(fn {_char, x} -> {x, y} end)
    end)
  end

  # Count how many asteroids are visible from a position
  defp count_visible(pos, asteroids) do
    asteroids
    |> Enum.reject(&(&1 == pos))
    |> Enum.map(&angle(pos, &1))
    |> Enum.uniq()
    |> length()
  end

  # Calculate unique angle identifier (normalized direction)
  defp angle({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    g = gcd(abs(dx), abs(dy))
    {div(dx, g), div(dy, g)}
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  # Vaporize asteroids in clockwise order starting from up
  defp vaporize_nth(station, asteroids, n) do
    # Group asteroids by angle, sort each group by distance
    groups =
      asteroids
      |> Enum.group_by(&clockwise_angle(station, &1))
      |> Enum.map(fn {angle, asts} ->
        sorted = Enum.sort_by(asts, &distance(station, &1))
        {angle, sorted}
      end)
      |> Enum.sort_by(fn {angle, _} -> angle end)

    # Vaporize in rounds
    vaporize_round(groups, n, 0)
  end

  defp vaporize_round(groups, n, count) do
    # Filter out empty groups
    active_groups = Enum.filter(groups, fn {_angle, asts} -> asts != [] end)

    if active_groups == [] do
      nil
    else
      # Take first asteroid from each group
      {vaporized, remaining_groups} =
        active_groups
        |> Enum.map_reduce([], fn {angle, [first | rest]}, acc ->
          {first, [{angle, rest} | acc]}
        end)

      new_count = count + length(vaporized)

      if new_count >= n do
        # The nth asteroid is in this round
        Enum.at(vaporized, n - count - 1)
      else
        # Continue to next round
        remaining = Enum.reverse(remaining_groups)
        vaporize_round(remaining, n, new_count)
      end
    end
  end

  # Calculate angle for clockwise ordering starting from up (north)
  # Returns angle in range [0, 2*pi) where 0 is straight up
  defp clockwise_angle({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    # atan2 returns angle from positive x-axis, counterclockwise
    # We want angle from negative y-axis (up), clockwise
    # atan2(dx, -dy) gives angle from up, counterclockwise
    # We negate to get clockwise, but easier to use atan2(dx, -dy) directly
    angle = :math.atan2(dx, -dy)
    # Normalize to [0, 2*pi)
    if angle < 0, do: angle + 2 * :math.pi(), else: angle
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end
