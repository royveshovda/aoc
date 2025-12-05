import AOC

aoc 2023, 24 do
  @moduledoc """
  https://adventofcode.com/2023/day/24

  Hailstone trajectories. Part 1: 2D intersections.
  Part 2: Find rock position that hits all hailstones.
  """

  @doc """
      iex> p1(example_string(), 7, 27)
      2

      iex> p1(input_string(), 200_000_000_000_000, 400_000_000_000_000)
      20847
  """
  def p1(input, min \\ 7, max \\ 27) do
    hailstones = parse(input)

    pairs(hailstones)
    |> Enum.count(fn {h1, h2} -> intersects_in_area?(h1, h2, min, max) end)
  end

  @doc """
      iex> p2(example_string())
      47

      iex> p2(input_string())
      908621716620524
  """
  def p2(input) do
    hailstones = parse(input)

    # Find rock velocity by trying candidates
    # If rock has velocity (rdx, rdy, rdz), then relative to rock, hailstones move at (dxi - rdx, dyi - rdy, dzi - rdz)
    # All hailstone paths (relative to rock) must pass through a single point (rock position)

    # Try velocity candidates
    max_v = 500
    {rdx, rdy} = find_xy_velocity(hailstones, max_v)
    rdz = find_z_velocity(hailstones, rdx, rdy, max_v)

    # Now find position
    # In rock frame, hailstone 0 moves from (x0, y0, z0) at velocity (dx0-rdx, dy0-rdy, dz0-rdz)
    # Rock position is where two hailstone paths intersect (in rock frame, rock is stationary)
    {x0, y0, z0, dx0, dy0, dz0} = hd(hailstones)
    {x1, y1, z1, dx1, dy1, dz1} = Enum.at(hailstones, 1)

    # Relative velocities
    {vx0, vy0, vz0} = {dx0 - rdx, dy0 - rdy, dz0 - rdz}
    {vx1, vy1, _vz1} = {dx1 - rdx, dy1 - rdy, dz1 - rdz}

    # Find intersection time for hailstone 0 and 1 (in XY plane)
    # x0 + t0*vx0 = x1 + t1*vx1
    # y0 + t0*vy0 = y1 + t1*vy1
    # Solve for t0
    det = vx0 * (-vy1) - (-vx1) * vy0
    t0 = div((x1 - x0) * (-vy1) - (y1 - y0) * (-vx1), det)

    rx = x0 + t0 * vx0
    ry = y0 + t0 * vy0
    rz = z0 + t0 * vz0

    rx + ry + rz
  end

  defp find_xy_velocity(hailstones, max_v) do
    h = Enum.take(hailstones, 3)

    Enum.find_value(-max_v..max_v, fn rdx ->
      Enum.find_value(-max_v..max_v, fn rdy ->
        if check_xy_velocity(h, rdx, rdy) do
          {rdx, rdy}
        end
      end)
    end)
  end

  defp check_xy_velocity(hailstones, rdx, rdy) do
    # Check if all hailstones (relative to rock velocity) pass through same XY point
    case hailstones do
      [h0, h1 | rest] ->
        case find_xy_intersection(h0, h1, rdx, rdy) do
          nil -> false
          {rx, ry} ->
            Enum.all?(rest, fn h -> passes_through_xy(h, rdx, rdy, rx, ry) end)
        end
      _ -> false
    end
  end

  defp find_xy_intersection({x0, y0, _, dx0, dy0, _}, {x1, y1, _, dx1, dy1, _}, rdx, rdy) do
    # Relative velocities
    vx0 = dx0 - rdx
    vy0 = dy0 - rdy
    vx1 = dx1 - rdx
    vy1 = dy1 - rdy

    det = vx0 * (-vy1) - (-vx1) * vy0
    if det == 0 do
      nil
    else
      # t0 and t1 must be non-negative integers for valid solution
      t0_num = (x1 - x0) * (-vy1) - (y1 - y0) * (-vx1)

      if rem(t0_num, det) != 0 do
        nil
      else
        t0 = div(t0_num, det)
        if t0 < 0 do
          nil
        else
          rx = x0 + t0 * vx0
          ry = y0 + t0 * vy0
          {rx, ry}
        end
      end
    end
  end

  defp passes_through_xy({x, y, _, dx, dy, _}, rdx, rdy, rx, ry) do
    vx = dx - rdx
    vy = dy - rdy

    cond do
      vx == 0 and vy == 0 -> x == rx and y == ry
      vx == 0 -> x == rx and rem(ry - y, vy) == 0 and div(ry - y, vy) >= 0
      vy == 0 -> y == ry and rem(rx - x, vx) == 0 and div(rx - x, vx) >= 0
      true ->
        rem(rx - x, vx) == 0 and rem(ry - y, vy) == 0 and
        div(rx - x, vx) == div(ry - y, vy) and div(rx - x, vx) >= 0
    end
  end

  defp find_z_velocity(hailstones, rdx, rdy, max_v) do
    [h0, h1 | _] = hailstones
    {x0, _, z0, dx0, _, dz0} = h0
    {x1, _, z1, dx1, _, dz1} = h1

    Enum.find_value(-max_v..max_v, fn rdz ->
      vx0 = dx0 - rdx
      vz0 = dz0 - rdz
      vx1 = dx1 - rdx
      vz1 = dz1 - rdz

      det = vx0 * (-vz1) - (-vx1) * vz0
      if det != 0 do
        t0_num = (x1 - x0) * (-vz1) - (z1 - z0) * (-vx1)
        if rem(t0_num, det) == 0 do
          t0 = div(t0_num, det)
          if t0 >= 0 do
            # Verify with another hailstone
            {x2, _, z2, dx2, _, dz2} = Enum.at(hailstones, 2)
            vx2 = dx2 - rdx
            vz2 = dz2 - rdz
            rz = z0 + t0 * vz0

            if vx2 == 0 do
              if x2 == x0 + t0 * vx0 do rdz end
            else
              t2_check = div(x0 + t0 * vx0 - x2, vx2)
              if z2 + t2_check * vz2 == rz do
                rdz
              end
            end
          end
        end
      end
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [pos, vel] = String.split(line, " @ ")
      [x, y, z] = pos |> String.split(", ") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
      [dx, dy, dz] = vel |> String.split(", ") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
      {x, y, z, dx, dy, dz}
    end)
  end

  defp pairs(list) do
    for {h1, i} <- Enum.with_index(list),
        {h2, j} <- Enum.with_index(list),
        i < j,
        do: {h1, h2}
  end

  defp intersects_in_area?({x1, y1, _, dx1, dy1, _}, {x2, y2, _, dx2, dy2, _}, min, max) do
    det = dx1 * (-dy2) - (-dx2) * dy1

    if det == 0 do
      false
    else
      t1 = ((x2 - x1) * (-dy2) - (y2 - y1) * (-dx2)) / det
      t2 = (dx1 * (y2 - y1) - dy1 * (x2 - x1)) / det

      if t1 >= 0 and t2 >= 0 do
        ix = x1 + t1 * dx1
        iy = y1 + t1 * dy1
        ix >= min and ix <= max and iy >= min and iy <= max
      else
        false
      end
    end
  end
end
