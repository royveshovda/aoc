import AOC

aoc 2024, 12 do
  @moduledoc """
  https://adventofcode.com/2024/day/12

  Garden Groups - flood fill regions:
  P1: sum of area × perimeter
  P2: sum of area × sides (count corners = count sides)
  """

  def p1(input) do
    grid = parse(input)
    regions = find_regions(grid)

    regions
    |> Enum.map(fn region ->
      area = MapSet.size(region)
      perim = perimeter(region, grid)
      area * perim
    end)
    |> Enum.sum()
  end

  def p2(input) do
    grid = parse(input)
    regions = find_regions(grid)

    regions
    |> Enum.map(fn region ->
      area = MapSet.size(region)
      sides = count_corners(region)
      area * sides
    end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Map.new()
  end

  defp find_regions(grid) do
    grid
    |> Map.keys()
    |> Enum.reduce({[], MapSet.new()}, fn pos, {regions, visited} ->
      if MapSet.member?(visited, pos) do
        {regions, visited}
      else
        region = flood_fill(pos, grid)
        {[region | regions], MapSet.union(visited, region)}
      end
    end)
    |> elem(0)
  end

  defp flood_fill(start, grid) do
    plant = Map.get(grid, start)
    do_flood([start], grid, plant, MapSet.new())
  end

  defp do_flood([], _grid, _plant, region), do: region

  defp do_flood([pos | rest], grid, plant, region) do
    if MapSet.member?(region, pos) or Map.get(grid, pos) != plant do
      do_flood(rest, grid, plant, region)
    else
      region = MapSet.put(region, pos)
      {x, y} = pos
      neighbors = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
      do_flood(neighbors ++ rest, grid, plant, region)
    end
  end

  defp perimeter(region, grid) do
    plant = Map.get(grid, Enum.at(region, 0))

    region
    |> Enum.map(fn {x, y} ->
      [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
      |> Enum.count(fn neighbor -> Map.get(grid, neighbor) != plant end)
    end)
    |> Enum.sum()
  end

  # Count corners = count sides of polygon
  defp count_corners(region) do
    region
    |> Enum.map(&corners_at(&1, region))
    |> Enum.sum()
  end

  defp corners_at({x, y}, region) do
    # Check all 4 corner directions: NW, NE, SW, SE
    # A corner exists if:
    # - Outer corner: both adjacent orthogonal neighbors are outside
    # - Inner corner: both adjacent orthogonal neighbors are inside, but diagonal is outside
    corner_checks = [
      {{x - 1, y}, {x, y - 1}, {x - 1, y - 1}},  # NW
      {{x + 1, y}, {x, y - 1}, {x + 1, y - 1}},  # NE
      {{x - 1, y}, {x, y + 1}, {x - 1, y + 1}},  # SW
      {{x + 1, y}, {x, y + 1}, {x + 1, y + 1}}   # SE
    ]

    Enum.count(corner_checks, fn {adj1, adj2, diag} ->
      in1 = MapSet.member?(region, adj1)
      in2 = MapSet.member?(region, adj2)
      in_diag = MapSet.member?(region, diag)

      # Outer corner: neither adjacent is in region
      # Inner corner: both adjacent in region, but diagonal not
      (not in1 and not in2) or (in1 and in2 and not in_diag)
    end)
  end
end
