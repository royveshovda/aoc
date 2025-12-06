import AOC

aoc 2022, 18 do
  @moduledoc """
  Day 18: Boiling Boulders

  Calculate surface area of 3D lava droplet.
  Part 1: Total surface area (including interior).
  Part 2: Exterior surface area only (flood fill from outside).
  """

  @doc """
  Part 1: Total surface area of all cubes.

  ## Examples

      iex> example = \"\"\"
      ...> 2,2,2
      ...> 1,2,2
      ...> 3,2,2
      ...> 2,1,2
      ...> 2,3,2
      ...> 2,2,1
      ...> 2,2,3
      ...> 2,2,4
      ...> 2,2,6
      ...> 1,2,5
      ...> 3,2,5
      ...> 2,1,5
      ...> 2,3,5
      ...> \"\"\"
      iex> Y2022.D18.p1(example)
      64

  """
  def p1(input) do
    cubes = parse(input)
    cubes
    |> Enum.map(fn cube -> 6 - count_neighbors(cube, cubes) end)
    |> Enum.sum()
  end

  @doc """
  Part 2: External surface area only.

  ## Examples

      iex> example = \"\"\"
      ...> 2,2,2
      ...> 1,2,2
      ...> 3,2,2
      ...> 2,1,2
      ...> 2,3,2
      ...> 2,2,1
      ...> 2,2,3
      ...> 2,2,4
      ...> 2,2,6
      ...> 1,2,5
      ...> 3,2,5
      ...> 2,1,5
      ...> 2,3,5
      ...> \"\"\"
      iex> Y2022.D18.p2(example)
      58

  """
  def p2(input) do
    cubes = parse(input)

    # Find bounding box with 1 cell padding
    {min_x, max_x} = cubes |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = cubes |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    {min_z, max_z} = cubes |> Enum.map(&elem(&1, 2)) |> Enum.min_max()

    bounds = {min_x - 1, max_x + 1, min_y - 1, max_y + 1, min_z - 1, max_z + 1}

    # Flood fill from outside to find all exterior cells
    start = {min_x - 1, min_y - 1, min_z - 1}
    exterior = flood_fill(start, cubes, bounds)

    # Count faces where lava cube touches exterior
    cubes
    |> Enum.map(fn cube -> count_exterior_faces(cube, exterior) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, z] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
      {x, y, z}
    end)
    |> MapSet.new()
  end

  defp neighbors({x, y, z}) do
    [{x+1, y, z}, {x-1, y, z}, {x, y+1, z}, {x, y-1, z}, {x, y, z+1}, {x, y, z-1}]
  end

  defp count_neighbors(cube, cubes) do
    neighbors(cube) |> Enum.count(&MapSet.member?(cubes, &1))
  end

  defp in_bounds?({x, y, z}, {min_x, max_x, min_y, max_y, min_z, max_z}) do
    x >= min_x and x <= max_x and y >= min_y and y <= max_y and z >= min_z and z <= max_z
  end

  defp flood_fill(start, cubes, bounds) do
    do_flood_fill(:queue.from_list([start]), MapSet.new([start]), cubes, bounds)
  end

  defp do_flood_fill(queue, visited, cubes, bounds) do
    case :queue.out(queue) do
      {:empty, _} -> visited
      {{:value, pos}, queue} ->
        {queue, visited} =
          neighbors(pos)
          |> Enum.filter(fn n ->
            in_bounds?(n, bounds) and
            not MapSet.member?(visited, n) and
            not MapSet.member?(cubes, n)
          end)
          |> Enum.reduce({queue, visited}, fn n, {q, v} ->
            {:queue.in(n, q), MapSet.put(v, n)}
          end)
        do_flood_fill(queue, visited, cubes, bounds)
    end
  end

  defp count_exterior_faces(cube, exterior) do
    neighbors(cube) |> Enum.count(&MapSet.member?(exterior, &1))
  end
end
