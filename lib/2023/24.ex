import AOC

aoc 2023, 24 do
  @moduledoc """
  https://adventofcode.com/2023/day/24

  Source: https://github.com/bjorng/advent-of-code-2023/blob/main/day24/lib/day24.ex
  Inspired by https://github.com/MarkSinke/aoc2023/blob/main/day24.go
  """

  @doc """
      iex> p1(example_string(), 7, 27)
      2

      iex> p1(input_string(), 200_000_000_000_000, 400_000_000_000_000)
      20847
  """
  def p1(input, min \\ 7, max \\ 27) do
    parse(input)
    |> Enum.map(fn {{px, py, _}, {vx, vy, _}} ->
      {{px, py}, {vx, vy}}
    end)
    |> intersections
    |> Enum.count(fn coordinate ->
      if coordinate === nil do
        false
      else
        {{x, y}, {{x1, y1}, {vx1, vy1}}, {{x2, y2}, {vx2, vy2}}} = coordinate
        min <= x and x <= max and min <= y and y <= max and
        (x - x1) * vx1 > 0 and
        (y - y1) * vy1 > 0 and
        (x - x2) * vx2 > 0 and
        (y - y2) * vy2 > 0
      end
    end)
  end


  @doc """
      iex> p2(example_string())
      47

      iex> p2(input_string())
      908621716620524
  """
  def p2(input) do
    hs = parse(input)

    [{h0_pos, h0_dir} | _] = hs

    # Use the first hailstone as reference, translating it to
    # the origin and making it stationary. The rock need to
    # pass through the origin.
    hs = hs
    |> Enum.take(4)
    |> Enum.map(fn {pos, dir} ->
      {sub(pos, h0_pos), sub(dir, h0_dir)}
    end)

    [_, {h1_pos, h1_dir}, h2, h3 | _] = hs

    # Find the plane common to all hailstones.
    n = cross(h1_pos, add(h1_pos, h1_dir))

    # Find the intersection with that plane for hailstones 2 and 3.
    p0 = zero()
    {p2, t2} = plane_and_line_intersection(p0, n, h2)
    {p3, t3} = plane_and_line_intersection(p0, n, h3)

    # Now find the position and direction of the rock.
    t_diff = t2 - t3
    dir = vec_div(sub(p2, p3), t_diff)
    pos = sub(p2, mul(dir, t2))

    # Translate back to the original frame of reference.
    pos = add(pos, h0_pos)
    # dir = add(dir, h0_dir)

    {x, y, z} = pos
    x + y + z
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" @ ")
      |> Enum.map(fn part ->
        String.split(part, [",", " "], trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple
      end)
      |> List.to_tuple
    end)
  end

  defp intersections(list), do: intersections(list, [])

  defp intersections([], acc), do: acc
  defp intersections([a | rest], acc) do
    intersections(rest, intersections(rest, a, acc))
  end

  defp intersections([], _a, acc), do: acc
  defp intersections([b | rest], a, acc) do
    intersections(rest, a, [intersection(a, b) | acc])
  end

  defp intersection(e1, e2) do
    {a, c} = line_equation(e1)
    {b, d} = line_equation(e2)
    if (a - b) == 0 do
      nil
    else
        x = (d - c) / (a - b)
        y = a * x + c
        {{x, y}, e1, e2}
    end
  end

  def line_equation({{px, py}, {vx, vy}}) do
    slope = vy / vx
    {slope, -slope * px + py}
  end

  defp sub({v10, v11, v12}, {v20, v21, v22}) do
    {v10 - v20, v11 - v21, v12 - v22}
  end

  defp cross({v10, v11, v12}, {v20, v21, v22}) do
    {v11 * v22 - v12 * v21, v12 * v20 - v10 * v22, v10 * v21 - v11 * v20}
  end

  defp add({v10, v11, v12}, {v20, v21, v22}) do
    {v10 + v20, v11 + v21, v12 + v22}
  end

  defp zero(), do: {0, 0, 0}

  defp plane_and_line_intersection(p0, n, {pos, dir}) do
    # https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
    a = dot(sub(p0, pos), n)
    b = dot(dir, n)
    t = div(a, b)
    p = add_prod(pos, dir, t)
    {p, t}
  end

  defp dot({v10, v11, v12}, {v20, v21, v22}) do
    v10 * v20 + v11 * v21 + v12 * v22
  end

  defp add_prod({v10, v11, v12}, {v20, v21, v22}, s) do
    {s * v20 + v10, s * v21 + v11, s * v22 + v12}
  end

  defp mul({v10, v11, v12}, s) do
    {v10 * s, v11 * s, v12 * s}
  end

  defp vec_div({v10, v11, v12}, s) do
    {div(v10, s), div(v11, s), div(v12, s)}
  end
end
