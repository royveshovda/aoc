import AOC

aoc 2025, 9 do
  @moduledoc """
  https://adventofcode.com/2025/day/9
  """

  @doc """
      iex> p1(example_string(0))
      50
  """
  def p1(input) do
    coords = parse(input)

    # Find the largest rectangle using any two tiles as opposite corners
    # Area = |x2 - x1| * |y2 - y1|
    for {x1, y1} <- coords,
        {x2, y2} <- coords,
        {x1, y1} != {x2, y2},
        reduce: 0 do
      acc ->
        # Area uses inclusive bounds: +1 for each dimension
        area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
        max(acc, area)
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y] =
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      {x, y}
    end)
  end

  @doc """
      iex> p2(example_string(0))
      24
  """
  def p2(input) do
    red_tiles = parse(input)

    # Build polygon segments (list of {start, end} for each edge)
    segments = build_segments(red_tiles)

    # For each pair of red tiles with indices i and j, check if rectangle is valid
    # A rectangle is valid if it doesn't cross any segment that's not between i and j
    indexed_tiles = Enum.with_index(red_tiles)
    n = length(red_tiles)

    for {tile1, i} <- indexed_tiles,
        {tile2, j} <- indexed_tiles,
        i < j,
        reduce: 0 do
      acc ->
        {x1, y1} = tile1
        {x2, y2} = tile2

        if rectangle_inside_polygon?(x1, y1, x2, y2, segments, i, j, n) do
          area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
          max(acc, area)
        else
          acc
        end
    end
  end

  defp build_segments(red_tiles) do
    # Build list of segments with their indices
    pairs = Enum.zip(red_tiles, tl(red_tiles) ++ [hd(red_tiles)])

    pairs
    |> Enum.with_index()
    |> Enum.map(fn {{p1, p2}, idx} -> {p1, p2, idx} end)
  end

  defp rectangle_inside_polygon?(x1, y1, x2, y2, segments, _i, _j, n) do
    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    # The rectangle edges are:
    # Top: y = min_y, from min_x to max_x
    # Bottom: y = max_y, from min_x to max_x
    # Left: x = min_x, from min_y to max_y
    # Right: x = max_x, from min_y to max_y

    # We need to check that no polygon segment crosses the rectangle interior
    # Segments on the path from i to j (going forward) should be inside or on the rectangle
    # Segments on the path from j to i (going forward, wrapping) should be outside or on the rectangle

    # Actually, simpler approach: check if all 4 corners are inside-or-on the polygon
    # and no polygon edge crosses through the rectangle interior

    # For rectilinear polygon: a rectangle is fully inside if:
    # 1. All 4 corners are inside or on the polygon
    # 2. No polygon edge crosses the rectangle interior (not just touches boundary)

    corners = [{min_x, min_y}, {min_x, max_y}, {max_x, min_y}, {max_x, max_y}]

    all_corners_inside = Enum.all?(corners, fn {cx, cy} ->
      point_inside_or_on_polygon?(cx, cy, segments, n)
    end)

    if not all_corners_inside do
      false
    else
      # Check no segment crosses through the rectangle interior
      not Enum.any?(segments, fn {p1, p2, _idx} ->
        segment_crosses_rectangle_interior?(p1, p2, min_x, max_x, min_y, max_y)
      end)
    end
  end

  defp point_inside_or_on_polygon?(px, py, segments, _n) do
    # Ray casting: count crossings to the right
    # For rectilinear polygons, this is simpler
    crossings =
      segments
      |> Enum.count(fn {{x1, y1}, {x2, y2}, _idx} ->
        cond do
          # Horizontal segment - check if point is on it
          y1 == y2 ->
            false  # Horizontal segments don't count for vertical ray

          # Vertical segment
          x1 == x2 ->
            seg_min_y = min(y1, y2)
            seg_max_y = max(y1, y2)
            # Ray goes right from (px, py)
            # Crosses if segment is to the right and spans py
            x1 > px and py >= seg_min_y and py < seg_max_y

          true ->
            false
        end
      end)

    # Also check if point is exactly on a segment
    on_segment = Enum.any?(segments, fn {{x1, y1}, {x2, y2}, _idx} ->
      cond do
        x1 == x2 ->  # Vertical segment
          px == x1 and py >= min(y1, y2) and py <= max(y1, y2)
        y1 == y2 ->  # Horizontal segment
          py == y1 and px >= min(x1, x2) and px <= max(x1, x2)
        true ->
          false
      end
    end)

    on_segment or rem(crossings, 2) == 1
  end

  defp segment_crosses_rectangle_interior?(p1, p2, min_x, max_x, min_y, max_y) do
    {x1, y1} = p1
    {x2, y2} = p2

    cond do
      # Vertical segment
      x1 == x2 ->
        seg_min_y = min(y1, y2)
        seg_max_y = max(y1, y2)
        # Crosses interior if x is strictly inside and y range overlaps interior
        x1 > min_x and x1 < max_x and seg_min_y < max_y and seg_max_y > min_y

      # Horizontal segment
      y1 == y2 ->
        seg_min_x = min(x1, x2)
        seg_max_x = max(x1, x2)
        # Crosses interior if y is strictly inside and x range overlaps interior
        y1 > min_y and y1 < max_y and seg_min_x < max_x and seg_max_x > min_x

      true ->
        false
    end
  end
end
