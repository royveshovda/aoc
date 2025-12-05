import AOC

aoc 2020, 12 do
  @moduledoc """
  https://adventofcode.com/2020/day/12

  Rain Risk - Ship navigation with directions and waypoints.
  """

  @doc """
  Navigate ship directly. Return Manhattan distance.

  ## Examples

      iex> p1("F10\\nN3\\nF7\\nR90\\nF11")
      25
  """
  def p1(input) do
    instructions = parse(input)
    {x, y, _dir} = Enum.reduce(instructions, {0, 0, :east}, &move_ship/2)
    abs(x) + abs(y)
  end

  @doc """
  Navigate with waypoint. Return Manhattan distance.

  ## Examples

      iex> p2("F10\\nN3\\nF7\\nR90\\nF11")
      286
  """
  def p2(input) do
    instructions = parse(input)
    # Ship at origin, waypoint at (10, 1)
    {ship_x, ship_y, _wx, _wy} =
      Enum.reduce(instructions, {0, 0, 10, 1}, &move_waypoint/2)
    abs(ship_x) + abs(ship_y)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      {action, value} = String.split_at(line, 1)
      {action, String.to_integer(value)}
    end)
  end

  # Part 1: Ship movement
  defp move_ship({"N", n}, {x, y, dir}), do: {x, y + n, dir}
  defp move_ship({"S", n}, {x, y, dir}), do: {x, y - n, dir}
  defp move_ship({"E", n}, {x, y, dir}), do: {x + n, y, dir}
  defp move_ship({"W", n}, {x, y, dir}), do: {x - n, y, dir}
  defp move_ship({"L", deg}, {x, y, dir}), do: {x, y, rotate(dir, -deg)}
  defp move_ship({"R", deg}, {x, y, dir}), do: {x, y, rotate(dir, deg)}
  defp move_ship({"F", n}, {x, y, dir}) do
    case dir do
      :north -> {x, y + n, dir}
      :south -> {x, y - n, dir}
      :east -> {x + n, y, dir}
      :west -> {x - n, y, dir}
    end
  end

  defp rotate(dir, deg) do
    dirs = [:north, :east, :south, :west]
    idx = Enum.find_index(dirs, &(&1 == dir))
    new_idx = rem(idx + div(deg, 90) + 4, 4)
    Enum.at(dirs, new_idx)
  end

  # Part 2: Waypoint movement
  defp move_waypoint({"N", n}, {sx, sy, wx, wy}), do: {sx, sy, wx, wy + n}
  defp move_waypoint({"S", n}, {sx, sy, wx, wy}), do: {sx, sy, wx, wy - n}
  defp move_waypoint({"E", n}, {sx, sy, wx, wy}), do: {sx, sy, wx + n, wy}
  defp move_waypoint({"W", n}, {sx, sy, wx, wy}), do: {sx, sy, wx - n, wy}
  defp move_waypoint({"L", deg}, {sx, sy, wx, wy}) do
    {new_wx, new_wy} = rotate_waypoint(wx, wy, -deg)
    {sx, sy, new_wx, new_wy}
  end
  defp move_waypoint({"R", deg}, {sx, sy, wx, wy}) do
    {new_wx, new_wy} = rotate_waypoint(wx, wy, deg)
    {sx, sy, new_wx, new_wy}
  end
  defp move_waypoint({"F", n}, {sx, sy, wx, wy}), do: {sx + wx * n, sy + wy * n, wx, wy}

  defp rotate_waypoint(wx, wy, deg) do
    case rem(deg + 360, 360) do
      0 -> {wx, wy}
      90 -> {wy, -wx}
      180 -> {-wx, -wy}
      270 -> {-wy, wx}
    end
  end
end
