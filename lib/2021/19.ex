import AOC

aoc 2021, 19 do
  @moduledoc """
  Day 19: Beacon Scanner

  Reconstruct 3D beacon map from overlapping scanner observations.
  Scanners have unknown positions and orientations (24 possible).
  Find where 12+ beacons overlap to determine scanner positions.
  """

  @doc """
  Part 1: Count total unique beacons.
  """
  def p1(input) do
    scanners = parse(input)
    {beacons, _scanner_positions} = align_scanners(scanners)
    MapSet.size(beacons)
  end

  @doc """
  Part 2: Find largest Manhattan distance between any two scanners.
  """
  def p2(input) do
    scanners = parse(input)
    {_beacons, scanner_positions} = align_scanners(scanners)

    for {x1, y1, z1} <- scanner_positions,
        {x2, y2, z2} <- scanner_positions do
      abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
    end
    |> Enum.max()
  end

  defp align_scanners([first | rest]) do
    # Use first scanner as reference frame
    known_beacons = MapSet.new(first)
    scanner_positions = [{0, 0, 0}]
    unaligned = rest

    align_loop(known_beacons, scanner_positions, unaligned)
  end

  defp align_loop(beacons, positions, []), do: {beacons, positions}

  defp align_loop(beacons, positions, unaligned) do
    # Try to align each unaligned scanner
    {newly_aligned, still_unaligned} =
      Enum.reduce(unaligned, {[], []}, fn scanner, {aligned, remaining} ->
        case try_align(beacons, scanner) do
          {:ok, transformed, position} ->
            {[{transformed, position} | aligned], remaining}

          :no_match ->
            {aligned, [scanner | remaining]}
        end
      end)

    if newly_aligned == [] do
      raise "Could not align any more scanners!"
    end

    # Add newly aligned beacons
    {new_beacons, new_positions} =
      Enum.reduce(newly_aligned, {beacons, positions}, fn {transformed, position}, {b, p} ->
        {MapSet.union(b, MapSet.new(transformed)), [position | p]}
      end)

    align_loop(new_beacons, new_positions, still_unaligned)
  end

  defp try_align(known_beacons, scanner) do
    # Try all 24 rotations
    Enum.find_value(rotations(), fn rotation ->
      rotated = Enum.map(scanner, &apply_rotation(&1, rotation))

      # Try to find translation that makes 12+ beacons match
      find_translation(known_beacons, rotated)
    end)
  end

  defp find_translation(known_beacons, rotated) do
    known_list = MapSet.to_list(known_beacons)

    # For each pair of beacons (one known, one rotated), compute translation
    # and check if 12+ beacons match
    Enum.find_value(known_list, fn known_beacon ->
      Enum.find_value(rotated, fn rotated_beacon ->
        translation = subtract(known_beacon, rotated_beacon)
        translated = Enum.map(rotated, &add(&1, translation))

        matching = Enum.count(translated, &MapSet.member?(known_beacons, &1))

        if matching >= 12 do
          {:ok, translated, translation}
        end
      end)
    end)
  end

  # All 24 rotation matrices for 3D
  defp rotations do
    [
      # Face +X
      fn {x, y, z} -> {x, y, z} end,
      fn {x, y, z} -> {x, -z, y} end,
      fn {x, y, z} -> {x, -y, -z} end,
      fn {x, y, z} -> {x, z, -y} end,
      # Face -X
      fn {x, y, z} -> {-x, -y, z} end,
      fn {x, y, z} -> {-x, z, y} end,
      fn {x, y, z} -> {-x, y, -z} end,
      fn {x, y, z} -> {-x, -z, -y} end,
      # Face +Y
      fn {x, y, z} -> {y, -x, z} end,
      fn {x, y, z} -> {y, z, x} end,
      fn {x, y, z} -> {y, x, -z} end,
      fn {x, y, z} -> {y, -z, -x} end,
      # Face -Y
      fn {x, y, z} -> {-y, x, z} end,
      fn {x, y, z} -> {-y, -z, x} end,
      fn {x, y, z} -> {-y, -x, -z} end,
      fn {x, y, z} -> {-y, z, -x} end,
      # Face +Z
      fn {x, y, z} -> {z, y, -x} end,
      fn {x, y, z} -> {z, x, y} end,
      fn {x, y, z} -> {z, -y, x} end,
      fn {x, y, z} -> {z, -x, -y} end,
      # Face -Z
      fn {x, y, z} -> {-z, y, x} end,
      fn {x, y, z} -> {-z, -x, y} end,
      fn {x, y, z} -> {-z, -y, -x} end,
      fn {x, y, z} -> {-z, x, -y} end
    ]
  end

  defp apply_rotation(point, rotation), do: rotation.(point)

  defp add({x1, y1, z1}, {x2, y2, z2}), do: {x1 + x2, y1 + y2, z1 + z2}
  defp subtract({x1, y1, z1}, {x2, y2, z2}), do: {x1 - x2, y1 - y2, z1 - z2}

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn section ->
      section
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> Enum.map(fn line ->
        [x, y, z] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
        {x, y, z}
      end)
    end)
  end
end
