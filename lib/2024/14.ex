import AOC

aoc 2024, 14 do
  @moduledoc """
  https://adventofcode.com/2024/day/14

  Restroom Redoubt - robots moving with wrap-around.
  P1: Safety factor = product of quadrant counts after 100 steps.
  P2: Find step where robots form Christmas tree (low variance cluster).
  """

  def p1({input, width, height}) do
    input
    |> parse()
    |> simulate(100, width, height)
    |> safety_factor(width, height)
  end

  def p2({input, width, height}) do
    robots = parse(input)
    find_tree(robots, 0, width, height)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [px, py, vx, vy] =
        Regex.scan(~r/-?\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
      {{px, py}, {vx, vy}}
    end)
  end

  defp simulate(robots, steps, width, height) do
    Enum.map(robots, fn {{px, py}, {vx, vy}} ->
      nx = Integer.mod(px + vx * steps, width)
      ny = Integer.mod(py + vy * steps, height)
      {nx, ny}
    end)
  end

  defp safety_factor(positions, width, height) do
    mx = div(width, 2)
    my = div(height, 2)

    positions
    |> Enum.reject(fn {x, y} -> x == mx or y == my end)
    |> Enum.group_by(fn {x, y} ->
      {x < mx, y < my}
    end)
    |> Map.values()
    |> Enum.map(&length/1)
    |> Enum.product()
  end

  # Christmas tree: look for step with many robots in same positions (clustering)
  # When all robots are at unique positions, they form the tree
  defp find_tree(robots, step, width, height) do
    positions = simulate(robots, step, width, height)
    unique = MapSet.new(positions) |> MapSet.size()

    if unique == length(robots) do
      step
    else
      find_tree(robots, step + 1, width, height)
    end
  end
end
