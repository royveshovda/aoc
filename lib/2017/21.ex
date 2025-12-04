import AOC

aoc 2017, 21 do
  @moduledoc """
  https://adventofcode.com/2017/day/21
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    rules = parse(input)
    start = [".#.", "..#", "###"]

    final = Enum.reduce(1..5, start, fn _, grid -> enhance(grid, rules) end)
    count_on(final)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    rules = parse(input)
    start = [".#.", "..#", "###"]

    final = Enum.reduce(1..18, start, fn _, grid -> enhance(grid, rules) end)
    count_on(final)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [pattern, result] = String.split(line, " => ")
      pattern_grid = String.split(pattern, "/")
      result_grid = String.split(result, "/")
      {pattern_grid, result_grid}
    end)
    |> Enum.flat_map(fn {pattern, result} ->
      # Generate all rotations and flips
      all_variants(pattern) |> Enum.map(fn variant -> {variant, result} end)
    end)
    |> Map.new()
  end

  defp all_variants(grid) do
    [
      grid,
      rotate(grid),
      rotate(rotate(grid)),
      rotate(rotate(rotate(grid))),
      flip_h(grid),
      flip_h(rotate(grid)),
      flip_h(rotate(rotate(grid))),
      flip_h(rotate(rotate(rotate(grid))))
    ]
    |> Enum.uniq()
  end

  defp rotate(grid) do
    size = length(grid)
    for row <- 0..(size - 1) do
      for col <- (size - 1)..0//-1 do
        grid |> Enum.at(col) |> String.at(row)
      end
      |> Enum.join()
    end
  end

  defp flip_h(grid) do
    Enum.map(grid, &String.reverse/1)
  end

  defp enhance(grid, rules) do
    size = length(grid)

    if rem(size, 2) == 0 do
      # Split into 2x2 blocks
      blocks_per_side = div(size, 2)

      new_blocks =
        for block_row <- 0..(blocks_per_side - 1) do
          for block_col <- 0..(blocks_per_side - 1) do
            block = extract_block(grid, block_row * 2, block_col * 2, 2)
            Map.fetch!(rules, block)
          end
        end

      join_blocks(new_blocks)
    else
      # Split into 3x3 blocks
      blocks_per_side = div(size, 3)

      new_blocks =
        for block_row <- 0..(blocks_per_side - 1) do
          for block_col <- 0..(blocks_per_side - 1) do
            block = extract_block(grid, block_row * 3, block_col * 3, 3)
            Map.fetch!(rules, block)
          end
        end

      join_blocks(new_blocks)
    end
  end

  defp extract_block(grid, row, col, size) do
    for r <- row..(row + size - 1) do
      grid
      |> Enum.at(r)
      |> String.slice(col, size)
    end
  end

  defp join_blocks(blocks) do
    # blocks is a list of rows of blocks
    # each block is a list of strings
    blocks
    |> Enum.flat_map(fn row_of_blocks ->
      # row_of_blocks is a list of blocks (each block is a list of strings)
      block_height = length(hd(row_of_blocks))

      for row_idx <- 0..(block_height - 1) do
        row_of_blocks
        |> Enum.map(fn block -> Enum.at(block, row_idx) end)
        |> Enum.join()
      end
    end)
  end

  defp count_on(grid) do
    grid
    |> Enum.join()
    |> String.graphemes()
    |> Enum.count(&(&1 == "#"))
  end
end
