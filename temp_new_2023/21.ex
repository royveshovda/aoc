import AOC

aoc 2023, 21 do
  @moduledoc """
  https://adventofcode.com/2023/day/21

  Step counter. Part 1: count reachable positions.
  Part 2: infinite grid with quadratic extrapolation.
  """

  @doc """
      iex> p1(example_string(), 6)
      16

      iex> p1(input_string())
      3795
  """
  def p1(input, steps_to_take \\ 64) do
    {grid, start, _, _} = parse(input)
    count_reachable(grid, start, steps_to_take)
  end

  @doc """
      iex> p2(input_string())
      630129824772393
  """
  def p2(input) do
    {grid, start, height, width} = parse(input)

    # The grid is 131x131, start is at center (65, 65)
    # 26501365 = 65 + 202300 * 131
    # We need to find the quadratic pattern
    target = 26_501_365
    cycle = width  # 131

    # Calculate values at 65, 65+131, 65+262 (three points for quadratic)
    base = rem(target, cycle)
    points = [
      count_reachable_infinite(grid, start, height, width, base),
      count_reachable_infinite(grid, start, height, width, base + cycle),
      count_reachable_infinite(grid, start, height, width, base + cycle * 2)
    ]

    [y0, y1, y2] = points

    # Lagrange interpolation / quadratic formula
    # f(n) = a*n^2 + b*n + c where n = (target - base) / cycle
    n = div(target - base, cycle)

    # Using finite differences for quadratic:
    # c = y0
    # a = (y2 - 2*y1 + y0) / 2
    # b = y1 - y0 - a
    c = y0
    a = div(y2 - 2 * y1 + y0, 2)
    b = y1 - y0 - a

    a * n * n + b * n + c
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    height = length(lines)
    width = String.length(hd(lines))

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, c} -> {{r, c}, char} end)
      end)
      |> Map.new()

    start = Enum.find_value(grid, fn {pos, char} -> if char == "S", do: pos end)
    grid = Map.put(grid, start, ".")

    {grid, start, height, width}
  end

  defp count_reachable(grid, start, steps) do
    do_bfs(grid, MapSet.new([start]), steps)
  end

  defp do_bfs(_grid, positions, 0), do: MapSet.size(positions)
  defp do_bfs(grid, positions, steps) do
    next = positions
           |> Enum.flat_map(fn {r, c} ->
             [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
           end)
           |> Enum.filter(fn pos -> Map.get(grid, pos) == "." end)
           |> MapSet.new()

    do_bfs(grid, next, steps - 1)
  end

  defp count_reachable_infinite(grid, start, height, width, steps) do
    do_bfs_infinite(grid, height, width, MapSet.new([start]), steps)
  end

  defp do_bfs_infinite(_grid, _h, _w, positions, 0), do: MapSet.size(positions)
  defp do_bfs_infinite(grid, h, w, positions, steps) do
    next = positions
           |> Enum.flat_map(fn {r, c} ->
             [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
           end)
           |> Enum.filter(fn {r, c} ->
             # Wrap coordinates to check in original grid
             Map.get(grid, {mod(r, h), mod(c, w)}) == "."
           end)
           |> MapSet.new()

    do_bfs_infinite(grid, h, w, next, steps - 1)
  end

  # Proper modulo that handles negative numbers
  defp mod(a, b) do
    rem(rem(a, b) + b, b)
  end
end
