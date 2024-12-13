import AOC

aoc 2024, 12 do
  @moduledoc """
  https://adventofcode.com/2024/day/12
  """

  def p1(input) do
    input
    |> Utils.Grid.input_to_map()
    |> regions()
    |> Enum.map(fn region -> {region, perimeter(region), area(region)} end)
    |> Enum.map(fn {_region, perimeter, area} -> perimeter * area end)
    |> Enum.sum()
  end

  def area(region) do
    MapSet.size(region)
  end

  def border_tiles(region) do
    Enum.filter(region, fn tile ->
      tile
      |> neighbors()
      |> Enum.any?(& &1 not in region)
    end)
  end

  def perimeter(region) do
    region
    |> border_tiles()
    |> Enum.map(fn tile ->
      tile
      |> neighbors()
      |> Enum.count(& &1 not in region)
    end)
    |> Enum.sum()
  end

  defp neighbors(tile) do
    [
      up(tile),
      down(tile),
      left(tile),
      right(tile)
    ]
  end

  defp up({i, j}) do
    {i - 1, j}
  end

  defp down({i, j}) do
    {i + 1, j}
  end

  defp left({i, j}) do
    {i, j - 1}
  end

  defp right({i, j}) do
    {i, j + 1}
  end

  def regions(garden) do
    garden
    |> regions([])
    |> Enum.map(&MapSet.new/1)
  end

  defp regions(garden, acc) when map_size(garden) == 0 do
    acc
  end

  defp regions(garden, acc) do
    {tile, plant} = Enum.at(garden, 0)
    {region, garden} = dfs_region(garden, plant, tile, [])
    regions(garden, [region | acc])
  end

  defp dfs_region(garden, plant, tile, acc) do
    if garden[tile] == plant do
      garden = Map.delete(garden, tile)
      acc = [tile | acc]

      for neighbor <- neighbors(tile), reduce: {acc, garden} do
        {acc, garden} -> dfs_region(garden, plant, neighbor, acc)
      end
    else
      {acc, garden}
    end
  end

  def p2(input) do
    input
    |> Utils.Grid.input_to_map()
    |> regions()
    |> Enum.map(fn region -> {region, sides(region), area(region)} end)
    |> Enum.map(fn {_region, sides, area} -> sides * area end)
    |> Enum.sum()
  end

  def sides(region) do
    border_tiles =
      region
      |> border_tiles()
      |> Enum.flat_map(fn tile ->
        acc = (up(tile) in region) && [] || [{tile, :up}]
        acc = (down(tile) in region) && acc || [{tile, :down} | acc]
        acc = (left(tile) in region) && acc || [{tile, :left} | acc]
        (right(tile) in region) && acc || [{tile, :right} | acc]
      end)
      |> MapSet.new()

    count_sides(border_tiles, 0)
  end

  defp count_sides(border_tiles, acc) do
    if MapSet.size(border_tiles) == 0 do
      acc
    else
      border_tiles = remove_border(border_tiles, Enum.min(border_tiles))
      count_sides(border_tiles, acc + 1)
    end
  end

  defp remove_border(border_tiles, {tile, dir} = entry) when dir in [:up, :down] do
    if entry in border_tiles do
      border_tiles = MapSet.delete(border_tiles, entry)
      remove_border(border_tiles, {right(tile), dir})
    else
      border_tiles
    end
  end

  defp remove_border(border_tiles, {tile, dir} = entry) when dir in [:left, :right] do
    if entry in border_tiles do
      border_tiles = MapSet.delete(border_tiles, entry)
      remove_border(border_tiles, {down(tile), dir})
    else
      border_tiles
    end
  end
end
