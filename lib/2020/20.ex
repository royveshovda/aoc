import AOC

aoc 2020, 20 do
  @moduledoc """
  https://adventofcode.com/2020/day/20

  Jurassic Jigsaw - Image tile assembly with rotations/flips.

  ## Examples

      iex> example = File.read!("input/2020_20_example_0.txt")
      iex> Y2020.D20.p1(example)
      20899048083289

      iex> example = File.read!("input/2020_20_example_0.txt")
      iex> Y2020.D20.p2(example)
      273
  """

  # Sea monster pattern
  @monster [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
  ]

  def p1(input) do
    tiles = parse(input)

    # Find corner tiles - they have exactly 2 edges that don't match any other tile
    edge_counts = count_edge_matches(tiles)

    corners =
      tiles
      |> Enum.filter(fn {id, _} ->
        unmatched = count_unmatched_edges(id, tiles, edge_counts)
        unmatched == 2
      end)
      |> Enum.map(fn {id, _} -> id end)

    Enum.product(corners)
  end

  def p2(input) do
    tiles = parse(input)
    edge_counts = count_edge_matches(tiles)

    # Assemble the image
    grid = assemble_grid(tiles, edge_counts)

    # Remove borders and create final image
    image = create_image(grid, tiles)

    # Find sea monsters in any orientation
    monster_coords = monster_coordinates()

    {oriented_image, monster_count} =
      all_orientations(image)
      |> Enum.map(fn img -> {img, count_monsters(img, monster_coords)} end)
      |> Enum.find(fn {_, count} -> count > 0 end)

    # Count # not part of monsters
    total_hashes = count_hashes(oriented_image)
    monster_hashes = length(monster_coords)

    total_hashes - monster_count * monster_hashes
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_tile/1)
    |> Map.new()
  end

  defp parse_tile(block) do
    [header | rows] = String.split(block, "\n", trim: true)
    [_, id_str] = Regex.run(~r/Tile (\d+):/, header)
    id = String.to_integer(id_str)

    grid =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, c} end)
      end)
      |> Map.new()

    {id, grid}
  end

  # Get all 4 edges of a tile (as strings, for easy comparison)
  defp get_edges(grid) do
    size = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()

    top = 0..size |> Enum.map(&Map.get(grid, {&1, 0})) |> Enum.join()
    bottom = 0..size |> Enum.map(&Map.get(grid, {&1, size})) |> Enum.join()
    left = 0..size |> Enum.map(&Map.get(grid, {0, &1})) |> Enum.join()
    right = 0..size |> Enum.map(&Map.get(grid, {size, &1})) |> Enum.join()

    [top, right, bottom, left]
  end

  # Get all possible edges (including flipped versions)
  defp get_all_edge_variants(grid) do
    edges = get_edges(grid)
    edges ++ Enum.map(edges, &String.reverse/1)
  end

  defp count_edge_matches(tiles) do
    tiles
    |> Enum.flat_map(fn {_id, grid} -> get_all_edge_variants(grid) end)
    |> Enum.frequencies()
  end

  defp count_unmatched_edges(id, tiles, edge_counts) do
    grid = Map.get(tiles, id)

    get_edges(grid)
    |> Enum.count(fn edge ->
      # Edge is unmatched if it (and its reverse) only appear once
      Map.get(edge_counts, edge, 0) == 1 and
        Map.get(edge_counts, String.reverse(edge), 0) == 1
    end)
  end

  # Rotate grid 90 degrees clockwise
  defp rotate(grid) do
    size = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()

    grid
    |> Enum.map(fn {{x, y}, v} -> {{size - y, x}, v} end)
    |> Map.new()
  end

  # Flip grid horizontally
  defp flip_h(grid) do
    size = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()

    grid
    |> Enum.map(fn {{x, y}, v} -> {{size - x, y}, v} end)
    |> Map.new()
  end

  # All 8 orientations (4 rotations x 2 flips)
  defp all_orientations(grid) do
    r0 = grid
    r1 = rotate(r0)
    r2 = rotate(r1)
    r3 = rotate(r2)

    [r0, r1, r2, r3, flip_h(r0), flip_h(r1), flip_h(r2), flip_h(r3)]
  end

  defp get_edge(grid, direction) do
    size = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()

    case direction do
      :top -> 0..size |> Enum.map(&Map.get(grid, {&1, 0})) |> Enum.join()
      :bottom -> 0..size |> Enum.map(&Map.get(grid, {&1, size})) |> Enum.join()
      :left -> 0..size |> Enum.map(&Map.get(grid, {0, &1})) |> Enum.join()
      :right -> 0..size |> Enum.map(&Map.get(grid, {size, &1})) |> Enum.join()
    end
  end

  defp assemble_grid(tiles, edge_counts) do
    grid_size = tiles |> map_size() |> :math.sqrt() |> round()

    # Find a corner to start with
    corner_id =
      tiles
      |> Enum.find(fn {id, _} -> count_unmatched_edges(id, tiles, edge_counts) == 2 end)
      |> elem(0)

    corner_grid = Map.get(tiles, corner_id)

    # Orient corner so unmatched edges are top and left
    oriented_corner =
      all_orientations(corner_grid)
      |> Enum.find(fn g ->
        top = get_edge(g, :top)
        left = get_edge(g, :left)
        Map.get(edge_counts, top, 0) == 1 and Map.get(edge_counts, left, 0) == 1
      end)

    # Build grid row by row
    placed = %{{0, 0} => {corner_id, oriented_corner}}
    remaining = Map.delete(tiles, corner_id)

    placed = fill_grid(placed, remaining, grid_size)
    placed
  end

  defp fill_grid(placed, remaining, _grid_size) when map_size(remaining) == 0, do: placed

  defp fill_grid(placed, remaining, grid_size) do
    # Find next empty position to fill
    {gx, gy} = find_next_position(placed, grid_size)

    # Find tile that fits
    {id, oriented} = find_fitting_tile(placed, remaining, gx, gy)

    new_placed = Map.put(placed, {gx, gy}, {id, oriented})
    new_remaining = Map.delete(remaining, id)

    fill_grid(new_placed, new_remaining, grid_size)
  end

  defp find_next_position(placed, grid_size) do
    for gy <- 0..(grid_size - 1), gx <- 0..(grid_size - 1) do
      {gx, gy}
    end
    |> Enum.find(fn pos -> not Map.has_key?(placed, pos) end)
  end

  defp find_fitting_tile(placed, remaining, gx, gy) do
    # Get constraints from neighbors
    left_edge =
      case Map.get(placed, {gx - 1, gy}) do
        nil -> nil
        {_, grid} -> get_edge(grid, :right)
      end

    top_edge =
      case Map.get(placed, {gx, gy - 1}) do
        nil -> nil
        {_, grid} -> get_edge(grid, :bottom)
      end

    remaining
    |> Enum.find_value(fn {id, grid} ->
      oriented =
        all_orientations(grid)
        |> Enum.find(fn g ->
          (left_edge == nil or get_edge(g, :left) == left_edge) and
            (top_edge == nil or get_edge(g, :top) == top_edge)
        end)

      if oriented, do: {id, oriented}, else: nil
    end)
  end

  defp create_image(grid, _tiles) do
    # Get tile size (without borders)
    {_, sample} = grid |> Map.values() |> hd()
    tile_size = sample |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    inner_size = tile_size - 1  # Size after removing borders (8 for 10x10 tiles)

    grid_size = grid |> map_size() |> :math.sqrt() |> round()

    # Build final image
    for gy <- 0..(grid_size - 1),
        gx <- 0..(grid_size - 1),
        {_, tile} = Map.get(grid, {gx, gy}),
        ty <- 1..(tile_size - 1),
        tx <- 1..(tile_size - 1),
        into: %{} do
      final_x = gx * inner_size + (tx - 1)
      final_y = gy * inner_size + (ty - 1)
      {{final_x, final_y}, Map.get(tile, {tx, ty})}
    end
  end

  defp monster_coordinates do
    @monster
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c == "#" end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
  end

  defp count_monsters(image, monster_coords) do
    max_x = image |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = image |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    monster_w = monster_coords |> Enum.map(&elem(&1, 0)) |> Enum.max()
    monster_h = monster_coords |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..(max_y - monster_h), x <- 0..(max_x - monster_w) do
      if monster_at?(image, monster_coords, x, y), do: 1, else: 0
    end
    |> Enum.sum()
  end

  defp monster_at?(image, monster_coords, ox, oy) do
    Enum.all?(monster_coords, fn {mx, my} ->
      Map.get(image, {ox + mx, oy + my}) == "#"
    end)
  end

  defp count_hashes(image) do
    image |> Map.values() |> Enum.count(&(&1 == "#"))
  end
end
