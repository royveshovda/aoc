# Grid Representation & Operations

## Overview
Grids are fundamental in AoC. Elixir maps with coordinate tuples as keys provide efficient, flexible grid representation.

## When to Use
- 2D/3D spatial problems
- Maze/pathfinding
- Cellular automaton
- Pattern matching in grids
- Sparse grids (not every cell filled)

## Used In
- Nearly every year has multiple grid problems
- 2024 Days 4, 6, 8, 12, 15, 16, 18, 20, 25
- 2023 Days 3, 10, 13, 14, 16, 17, 18, 21, 23
- 2022 Days 8, 9, 12, 14, 17, 22, 23, 24

## Basic Grid Parsing

```elixir
def parse_grid(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, row} ->
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, col} -> {{row, col}, char} end)
  end)
  |> Map.new()
end

# Alternative with coordinate system (x, y) where y increases upward
def parse_grid_xy(input) do
  lines = String.split(input, "\n", trim: true)
  height = length(lines)
  
  lines
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, row} ->
    y = height - row - 1  # Flip y-axis
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, x} -> {{x, y}, char} end)
  end)
  |> Map.new()
end
```

## Using Utils.Grid (if available)

```elixir
# Assumes you have a Utils.Grid module
grid = Utils.Grid.input_to_map(input)
# Returns map with {x, y} => character
```

## Grid Neighbors (4-directional)

```elixir
def neighbors_4({x, y}) do
  [
    {x + 1, y},
    {x - 1, y},
    {x, y + 1},
    {x, y - 1}
  ]
end

# With bounds checking
def valid_neighbors_4({x, y}, grid) do
  neighbors_4({x, y})
  |> Enum.filter(&Map.has_key?(grid, &1))
end

# With value filtering
def valid_neighbors_4({x, y}, grid, allowed_values) do
  neighbors_4({x, y})
  |> Enum.filter(fn pos -> Map.get(grid, pos) in allowed_values end)
end
```

## Grid Neighbors (8-directional)

```elixir
def neighbors_8({x, y}) do
  [
    {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
    {x - 1, y},                 {x + 1, y},
    {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
  ]
end

def valid_neighbors_8({x, y}, grid) do
  neighbors_8({x, y})
  |> Enum.filter(&Map.has_key?(grid, &1))
end
```

## Grid Dimensions

```elixir
def get_dimensions(grid) do
  {min_x, max_x} = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
  {min_y, max_y} = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
  
  {{min_x, max_x}, {min_y, max_y}}
end

def get_size(grid) do
  {{min_x, max_x}, {min_y, max_y}} = get_dimensions(grid)
  {max_x - min_x + 1, max_y - min_y + 1}
end
```

## Grid Printing/Visualization

```elixir
def print_grid(grid, default \\ ".") do
  {{min_x, max_x}, {min_y, max_y}} = get_dimensions(grid)
  
  for y <- min_y..max_y do
    for x <- min_x..max_x do
      Map.get(grid, {x, y}, default)
    end
    |> Enum.join()
  end
  |> Enum.join("\n")
  |> IO.puts()
  
  grid
end

# Print with custom renderer
def print_grid(grid, renderer) when is_function(renderer) do
  {{min_x, max_x}, {min_y, max_y}} = get_dimensions(grid)
  
  for y <- min_y..max_y do
    for x <- min_x..max_x do
      renderer.({x, y}, Map.get(grid, {x, y}))
    end
    |> Enum.join()
  end
  |> Enum.join("\n")
  |> IO.puts()
  
  grid
end
```

## Finding Positions

```elixir
def find_positions(grid, value) do
  grid
  |> Enum.filter(fn {_pos, v} -> v == value end)
  |> Enum.map(&elem(&1, 0))
end

def find_first(grid, value) do
  grid
  |> Enum.find(fn {_pos, v} -> v == value end)
  |> case do
    {pos, _} -> pos
    nil -> nil
  end
end
```

## Grid Transformations

```elixir
# Rotate 90 degrees clockwise
def rotate_cw(grid) do
  grid
  |> Enum.map(fn {{x, y}, v} -> {{y, -x}, v} end)
  |> Map.new()
end

# Rotate 90 degrees counter-clockwise
def rotate_ccw(grid) do
  grid
  |> Enum.map(fn {{x, y}, v} -> {{-y, x}, v} end)
  |> Map.new()
end

# Flip horizontally
def flip_h(grid) do
  grid
  |> Enum.map(fn {{x, y}, v} -> {{-x, y}, v} end)
  |> Map.new()
end

# Flip vertically
def flip_v(grid) do
  grid
  |> Enum.map(fn {{x, y}, v} -> {{x, -y}, v} end)
  |> Map.new()
end

# Transpose (swap x and y)
def transpose(grid) do
  grid
  |> Enum.map(fn {{x, y}, v} -> {{y, x}, v} end)
  |> Map.new()
end
```

## Direction Vectors

```elixir
# Cardinal directions
@north {0, 1}
@south {0, -1}
@east {1, 0}
@west {-1, 0}

@directions %{
  north: {0, 1},
  south: {0, -1},
  east: {1, 0},
  west: {-1, 0}
}

def move({x, y}, {dx, dy}), do: {x + dx, y + dy}

# Direction rotation
def rotate_right({dx, dy}), do: {dy, -dx}
def rotate_left({dx, dy}), do: {-dy, dx}
def reverse({dx, dy}), do: {-dx, -dy}

# Named direction rotation (2024 Day 6)
def turn_right(:north), do: :east
def turn_right(:east), do: :south
def turn_right(:south), do: :west
def turn_right(:west), do: :north

def turn_left(:north), do: :west
def turn_left(:west), do: :south
def turn_left(:south), do: :east
def turn_left(:east), do: :north
```

## Sliding/Moving Elements (2024 Day 15)

```elixir
def slide_elements(grid, positions, direction) do
  # Remove elements from old positions
  cleared_grid = Enum.reduce(positions, grid, fn pos, g ->
    Map.put(g, pos, ".")
  end)
  
  # Add elements at new positions
  Enum.reduce(positions, cleared_grid, fn pos, g ->
    new_pos = move(pos, direction)
    Map.put(g, new_pos, grid[pos])
  end)
end
```

## Grid Expansion (2024 Day 15 Part 2)

```elixir
def widen_grid(grid) do
  grid
  |> Enum.flat_map(fn {{x, y}, char} ->
    case char do
      "#" -> [{{x * 2, y}, "#"}, {{x * 2 + 1, y}, "#"}]
      "O" -> [{{x * 2, y}, "["}, {{x * 2 + 1, y}, "]"}]
      "." -> [{{x * 2, y}, "."}, {{x * 2 + 1, y}, "."}]
      "@" -> [{{x * 2, y}, "@"}, {{x * 2 + 1, y}, "."}]
    end
  end)
  |> Map.new()
end
```

## Sparse Grid with MapSet (2022 Day 14, 23)

```elixir
# For grids where most cells are empty, use MapSet to store only filled cells
def parse_sparse_grid(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, row} ->
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char == "#" end)
    |> Enum.map(fn {_, col} -> {row, col} end)
  end)
  |> MapSet.new()
end

def has_obstacle?(sparse_grid, pos) do
  MapSet.member?(sparse_grid, pos)
end
```

## 3D Grid

```elixir
def neighbors_6({x, y, z}) do
  [
    {x + 1, y, z}, {x - 1, y, z},
    {x, y + 1, z}, {x, y - 1, z},
    {x, y, z + 1}, {x, y, z - 1}
  ]
end

# For 3D visualization/debugging
def print_3d_slice(grid, z_value) do
  grid
  |> Enum.filter(fn {{_, _, z}, _} -> z == z_value end)
  |> Enum.map(fn {{x, y, _}, v} -> {{x, y}, v} end)
  |> Map.new()
  |> print_grid()
end
```

## Grid Rotation Operations

**Problem:** Rotate rows or columns in a grid (like LCD screen operations).

**When to Use:**
- Display/screen simulation problems (2016 Day 8)
- Image transformation
- Circular shift operations on grid rows/columns

```elixir
# Rotate a row right by n positions
defp rotate_row(grid, row, shift, width) do
  # Collect all values in the row
  old_values = for x <- 0..(width - 1), do: {x, grid[{x, row}]}
  
  # Place each value at its new position
  Enum.reduce(old_values, grid, fn {x, val}, acc ->
    new_x = rem(x + shift, width)
    Map.put(acc, {new_x, row}, val)
  end)
end

# Rotate a column down by n positions
defp rotate_column(grid, col, shift, height) do
  # Collect all values in the column
  old_values = for y <- 0..(height - 1), do: {y, grid[{col, y}]}
  
  # Place each value at its new position
  Enum.reduce(old_values, grid, fn {y, val}, acc ->
    new_y = rem(y + shift, height)
    Map.put(acc, {col, new_y}, val)
  end)
end

# Alternative: Using Enum.zip to rotate
defp rotate_row_zip(grid, row, shift, width) do
  indices = 0..(width - 1) |> Enum.to_list()
  shifted_indices = Enum.drop(indices, -shift) ++ Enum.take(indices, -shift)
  
  Enum.zip(indices, shifted_indices)
  |> Enum.reduce(grid, fn {old_x, new_x}, acc ->
    Map.put(acc, {new_x, row}, grid[{old_x, row}])
  end)
end
```

**Pattern:** Collect old values → calculate new positions → update map

**Performance:** O(n) where n is row/column length. Use `rem` for wrap-around.

## Matrix Transpose for Column Processing

**Problem:** Process data by columns instead of rows.

**When to Use:**
- Finding patterns in columns (2016 Day 6)
- Vertical analysis of grid data
- Rotating grid 90 degrees

```elixir
# Transpose rows to columns for processing
defp parse_columns(input) do
  input
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.graphemes/1)
  |> Enum.zip()  # Zip rows into columns
  |> Enum.map(&Tuple.to_list/1)
end

# Example: Find most common character per column
defp decode_by_columns(input) do
  input
  |> parse_columns()
  |> Enum.map(fn column ->
    column
    |> Enum.frequencies()
    |> Enum.max_by(fn {_char, count} -> count end)
    |> elem(0)
  end)
  |> Enum.join()
end

# 90-degree rotation using transpose + reverse
defp rotate_90_clockwise(grid) do
  grid
  |> Enum.sort()  # Sort by coordinates
  |> Enum.group_by(fn {{x, _y}, _} -> x end)  # Group by column
  |> Enum.sort()
  |> Enum.map(fn {_, col} -> Enum.reverse(col) end)
  # ... transform back to grid map
end
```

**Key Insight:** `Enum.zip/1` transposes list of lists elegantly.

## Key Points
- **Map with Tuple Keys**: `%{{x, y} => value}` is idiomatic Elixir
- **Sparse Grids**: Use MapSet when most cells are empty/default
- **Coordinate System**: Be consistent (row/col vs x/y, which direction is "up")
- **Immutability**: Grid updates return new map, use reduce for multiple updates
- **Performance**: Maps are efficient for random access, MapSet for membership testing
- **Visualization**: Print grid for debugging, especially during development

## Common Grid Algorithms
- **Flood Fill**: DFS/BFS to find connected regions
- **Pathfinding**: BFS for shortest path, Dijkstra/A* for weighted
- **Pattern Matching**: Find specific shapes or arrangements
- **Cellular Automaton**: Update all cells based on neighbor states
- **Ray Casting**: Shoot rays to detect intersections (2023 Day 10)
