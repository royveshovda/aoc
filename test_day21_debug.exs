# Test that the grid operations work correctly
grid = [".#.", "..#", "###"]
IO.inspect(grid, label: "Original")
IO.inspect(length(grid), label: "Size")

# Try to extract a 3x3 block
extract_block = fn grid, row, col, size ->
  for r <- row..(row + size - 1) do
    grid
    |> Enum.at(r)
    |> String.slice(col, size)
  end
end

block = extract_block.(grid, 0, 0, 3)
IO.inspect(block, label: "Extracted block")

# Test rotation
rotate = fn grid ->
  size = length(grid)
  for row <- 0..(size - 1) do
    for col <- (size - 1)..0//-1 do
      grid |> Enum.at(col) |> String.at(row)
    end
    |> Enum.join()
  end
end

rotated = rotate.(grid)
IO.inspect(rotated, label: "Rotated once")
