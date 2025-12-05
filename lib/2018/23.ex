import AOC

aoc 2018, 23 do
  @moduledoc """
  https://adventofcode.com/2018/day/23

  Day 23: Experimental Emergency Teleportation - Nanobots with signal ranges
  """

  @doc """
  Part 1: Find nanobot with largest radius, count how many nanobots are in its range

  ## Examples

      iex> input = "pos=<0,0,0>, r=4\\npos=<1,0,0>, r=1\\npos=<4,0,0>, r=3\\npos=<0,2,0>, r=1\\npos=<0,5,0>, r=3\\npos=<0,0,3>, r=1\\npos=<1,1,1>, r=1\\npos=<1,1,2>, r=1\\npos=<1,3,1>, r=1"
      iex> p1(input)
      7
  """
  def p1(input) do
    nanobots = parse_input(input)

    # Find the nanobot with the largest radius
    strongest = Enum.max_by(nanobots, fn {_pos, r} -> r end)
    {strongest_pos, strongest_radius} = strongest

    # Count how many nanobots are in range of the strongest
    nanobots
    |> Enum.count(fn {pos, _r} ->
      manhattan_distance(strongest_pos, pos) <= strongest_radius
    end)
  end

  def p2(input) do
    nanobots = parse_input(input)

    # Find the position in range of the most nanobots
    # Use an octree/subdivision approach: start with large cube containing all bots,
    # subdivide regions and search for best area
    find_best_position(nanobots)
  end

  defp find_best_position(nanobots) do
    # Find the bounding box of all nanobots
    {min_coord, max_coord} = find_bounds(nanobots)

    # Start with a cube containing all space - use power of 2 for clean subdivision
    initial_size = next_power_of_2(max(abs(min_coord), abs(max_coord)) * 2)

    # Center the initial region around origin
    offset = -div(initial_size, 2)
    initial_region = {offset, offset, offset, initial_size}

    # Use priority queue to search: {-count, distance, x, y, z, size}
    # Priority: maximize count, then minimize distance
    count = count_in_range(initial_region, nanobots)
    dist = 0  # Distance from origin to closest point in region

    pq = Heap.new() |> Heap.push({-count, dist, initial_region})

    search_regions(pq, nanobots)
  end

  defp next_power_of_2(n) do
    :math.pow(2, :math.ceil(:math.log2(n))) |> round()
  end

  defp find_bounds(nanobots) do
    coords = Enum.flat_map(nanobots, fn {{x, y, z}, r} ->
      [x - r, x + r, y - r, y + r, z - r, z + r]
    end)

    {Enum.min(coords), Enum.max(coords)}
  end

  # Search regions using priority queue
  defp search_regions(pq, nanobots) do
    if Heap.empty?(pq) do
      nil
    else
      {_neg_count, _dist, region} = Heap.root(pq)
      rest_pq = Heap.pop(pq)

      {x, y, z, size} = region

      if size == 1 do
        # Found a point - this is our answer
        manhattan_distance({x, y, z}, {0, 0, 0})
      else
        # Subdivide into 8 smaller regions
        new_size = div(size, 2)

        subdivisions = for dx <- [0, new_size],
                           dy <- [0, new_size],
                           dz <- [0, new_size] do
          {x + dx, y + dy, z + dz, new_size}
        end

        # Add all subdivisions to priority queue
        new_pq = Enum.reduce(subdivisions, rest_pq, fn sub, acc_pq ->
          count = count_in_range(sub, nanobots)
          {sx, sy, sz, ssize} = sub
          # Distance to closest point in region from origin
          sub_dist = closest_distance_to_region({0, 0, 0}, {sx, sy, sz, ssize})

          Heap.push(acc_pq, {-count, sub_dist, sub})
        end)

        search_regions(new_pq, nanobots)
      end
    end
  end

  # Count how many nanobots can reach this region
  defp count_in_range({x, y, z, size}, nanobots) do
    # Check if region overlaps with each nanobot's range
    Enum.count(nanobots, fn {{nx, ny, nz}, r} ->
      # Distance from nanobot to closest point in region
      dist = closest_distance_to_region({nx, ny, nz}, {x, y, z, size})
      dist <= r
    end)
  end

  # Find closest distance from point to region (cube)
  defp closest_distance_to_region({px, py, pz}, {rx, ry, rz, size}) do
    dx = cond do
      px < rx -> rx - px
      px >= rx + size -> px - (rx + size - 1)
      true -> 0
    end

    dy = cond do
      py < ry -> ry - py
      py >= ry + size -> py - (ry + size - 1)
      true -> 0
    end

    dz = cond do
      pz < rz -> rz - pz
      pz >= rz + size -> pz - (rz + size - 1)
      true -> 0
    end

    dx + dy + dz
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_nanobot/1)
  end

  defp parse_nanobot(line) do
    # Parse: pos=<x,y,z>, r=radius
    [pos_part, r_part] = String.split(line, ", ")

    "pos=<" <> pos_str = pos_part
    pos_str = String.trim_trailing(pos_str, ">")
    [x, y, z] = String.split(pos_str, ",") |> Enum.map(&String.to_integer/1)

    "r=" <> r_str = r_part
    radius = String.to_integer(r_str)

    {{x, y, z}, radius}
  end

  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end
end
