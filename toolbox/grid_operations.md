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

## List-of-Strings Grid Transformations (2017 Day 21)

When grids are represented as lists of strings (common for pattern matching):

```elixir
# Rotate 90 degrees clockwise
def rotate(grid) do
  size = length(grid)
  for row <- 0..(size - 1) do
    for col <- (size - 1)..0//-1 do
      grid |> Enum.at(col) |> String.at(row)
    end
    |> Enum.join()
  end
end

# Flip horizontally
def flip_h(grid) do
  Enum.map(grid, &String.reverse/1)
end

# Flip vertically
def flip_v(grid) do
  Enum.reverse(grid)
end

# Generate all 8 unique orientations (rotations + flips)
def all_orientations(grid) do
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

# Split grid into blocks (2017 Day 21)
def split_into_blocks(grid, block_size) do
  size = length(grid)
  blocks_per_side = div(size, block_size)
  
  for block_row <- 0..(blocks_per_side - 1) do
    for block_col <- 0..(blocks_per_side - 1) do
      extract_block(grid, block_row * block_size, block_col * block_size, block_size)
    end
  end
end

defp extract_block(grid, row, col, size) do
  for r <- row..(row + size - 1) do
    grid |> Enum.at(r) |> String.slice(col, size)
  end
end

# Join blocks back into a single grid
def join_blocks(blocks) do
  blocks
  |> Enum.flat_map(fn row_of_blocks ->
    block_height = length(hd(row_of_blocks))
    
    for row_idx <- 0..(block_height - 1) do
      row_of_blocks
      |> Enum.map(fn block -> Enum.at(block, row_idx) end)
      |> Enum.join()
    end
  end)
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

## Spiral Grid Generation (2017 Day 3)

### Mathematical Spiral Position (Part 1)

For calculating Manhattan distance without building the spiral:

```elixir
def spiral_manhattan_distance(n) do
  # Find which ring the number is on
  ring = ceil((:math.sqrt(n) - 1) / 2)
  
  # Max number in this ring
  max_in_ring = (2 * ring + 1) * (2 * ring + 1)
  
  # Side length of this ring
  side_length = 2 * ring
  
  # Position in ring (0-indexed from start of ring)
  pos_in_ring = max_in_ring - n
  
  # Find offset from middle of side
  offset = rem(pos_in_ring, side_length)
  offset_from_middle = abs(offset - ring)
  
  ring + offset_from_middle
end
```

### Building Spiral with Values (Part 2)

For generating spiral where each cell depends on neighbors:

```elixir
def build_spiral_until(target) do
  grid = %{{0, 0} => 1}
  {x, y} = {1, 0}
  
  find_first_larger(grid, x, y, target)
end

defp find_first_larger(grid, x, y, target) do
  # Sum all 8 neighbors
  sum = 
    [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
    |> Enum.reduce(0, fn {dx, dy}, acc ->
      acc + Map.get(grid, {x + dx, y + dy}, 0)
    end)
  
  if sum > target do
    sum
  else
    new_grid = Map.put(grid, {x, y}, sum)
    {next_x, next_y} = next_spiral_pos(x, y, new_grid)
    find_first_larger(new_grid, next_x, next_y, target)
  end
end

defp next_spiral_pos(x, y, grid) do
  # Spiral pattern: right, up, left, down
  # Always try to turn left (counterclockwise) first
  right = {x + 1, y}
  up = {x, y - 1}
  left = {x - 1, y}
  down = {x, y + 1}
  
  cond do
    # Can turn left from current direction
    not Map.has_key?(grid, right) and Map.has_key?(grid, down) -> right
    not Map.has_key?(grid, up) and Map.has_key?(grid, right) -> up
    not Map.has_key?(grid, left) and Map.has_key?(grid, up) -> left
    not Map.has_key?(grid, down) and Map.has_key?(grid, left) -> down
    # Continue straight
    not Map.has_key?(grid, right) -> right
    not Map.has_key?(grid, up) -> up
    not Map.has_key?(grid, left) -> left
    true -> down
  end
end
```

**Key Insight for Spirals**: Check if you can turn left (counterclockwise), otherwise continue straight. This naturally creates the spiral pattern without tracking explicit state.

## Hexagonal Grids (Cube Coordinates)

Hexagonal grids can be efficiently represented using cube coordinates `{x, y, z}` where `x + y + z = 0`.

**Used In**: 2017 Day 11

### Hex Movement (6 directions)

```elixir
def hex_move({x, y, z}, "n"),  do: {x, y + 1, z - 1}
def hex_move({x, y, z}, "ne"), do: {x + 1, y, z - 1}
def hex_move({x, y, z}, "se"), do: {x + 1, y - 1, z}
def hex_move({x, y, z}, "s"),  do: {x, y - 1, z + 1}
def hex_move({x, y, z}, "sw"), do: {x - 1, y, z + 1}
def hex_move({x, y, z}, "nw"), do: {x - 1, y + 1, z}

# Apply a sequence of moves
def follow_hex_path(moves) do
  Enum.reduce(moves, {0, 0, 0}, &hex_move(&2, &1))
end
```

### Hex Distance (Manhattan-style on cube coordinates)

```elixir
def hex_distance({x, y, z}) do
  div(abs(x) + abs(y) + abs(z), 2)
end

# Distance between two hex positions
def hex_distance_between(pos1, pos2) do
  {x1, y1, z1} = pos1
  {x2, y2, z2} = pos2
  hex_distance({x1 - x2, y1 - y2, z1 - z2})
end
```

**Key Properties**:
- Constraint: `x + y + z = 0` always holds
- Distance formula works because moving one step changes two coordinates by ±1
- Simpler than offset or axial coordinate systems for distance calculations

## ASCII Path Following

Track position and direction, follow pipes/lines, handle turns at `+` intersections.

**Used In**: 2017 Day 19

```elixir
def follow_path(grid, start_pos, start_dir) do
  follow(grid, start_pos, start_dir, [], 0)
end

defp follow(grid, {x, y}, {dx, dy}, letters, steps) do
  next_pos = {x + dx, y + dy}
  
  case Map.get(grid, next_pos) do
    nil -> {Enum.reverse(letters), steps}
    "+" -> follow(grid, next_pos, find_turn(grid, next_pos, {dx, dy}), letters, steps + 1)
    c when c in ["|", "-"] -> follow(grid, next_pos, {dx, dy}, letters, steps + 1)
    letter -> follow(grid, next_pos, {dx, dy}, [letter | letters], steps + 1)
  end
end

defp find_turn(grid, {x, y}, {dx, _dy}) do
  # If moving vertically, try horizontal; if horizontal, try vertical
  candidates = if dx == 0, do: [{1, 0}, {-1, 0}], else: [{0, 1}, {0, -1}]
  Enum.find(candidates, fn {ndx, ndy} -> Map.has_key?(grid, {x + ndx, y + ndy}) end)
end
```

**Pattern**: At `+` junctions, try perpendicular directions to find the continuing path.

## Summed Area Table (Integral Image) - 2018 Day 11

For efficiently calculating sum of any rectangle in O(1) time after O(N) preprocessing.

**Problem**: Find square of any size with maximum sum in large grid (e.g., 300×300).

**Naive Approach**: O(N² × M²) - for each position, calculate sum of each size square
**Optimized**: O(N²) preprocessing + O(1) per query using summed area table

```elixir
# Build summed area table: SAT[x,y] = sum of all cells from (1,1) to (x,y)
def build_summed_area_table(grid) do
  # Assuming grid is Map with {x, y} => value, where x,y start at 1
  {max_x, max_y} = get_grid_bounds(grid)
  
  for x <- 1..max_x, y <- 1..max_y, reduce: %{} do
    sat ->
      value = Map.get(grid, {x, y}, 0)
      above = Map.get(sat, {x, y - 1}, 0)
      left = Map.get(sat, {x - 1, y}, 0)
      diagonal = Map.get(sat, {x - 1, y - 1}, 0)
      
      # Inclusion-exclusion principle
      Map.put(sat, {x, y}, value + above + left - diagonal)
  end
end

# Query sum of rectangle from (x1, y1) to (x2, y2) in O(1)
def rectangle_sum(sat, x1, y1, x2, y2) do
  total = Map.get(sat, {x2, y2}, 0)
  above = Map.get(sat, {x2, y1 - 1}, 0)
  left = Map.get(sat, {x1 - 1, y2}, 0)
  diagonal = Map.get(sat, {x1 - 1, y1 - 1}, 0)
  
  total - above - left + diagonal
end

# Calculate sum of size×size square starting at (x, y)
def square_sum(sat, x, y, size) do
  rectangle_sum(sat, x, y, x + size - 1, y + size - 1)
end

# Example: Find best square of any size
def find_best_square(grid, max_size) do
  sat = build_summed_area_table(grid)
  {max_x, max_y} = get_grid_bounds(grid)
  
  for size <- 1..max_size,
      x <- 1..(max_x - size + 1),
      y <- 1..(max_y - size + 1) do
    sum = square_sum(sat, x, y, size)
    {x, y, size, sum}
  end
  |> Enum.max_by(fn {_x, _y, _size, sum} -> sum end)
end
```

**Visualization** of SAT calculation:
```
Grid:      SAT:
1 2 3      1  3  6
4 5 6      5 12 21
7 8 9     12 27 45
```

**Formula**: `SAT[x,y] = Grid[x,y] + SAT[x-1,y] + SAT[x,y-1] - SAT[x-1,y-1]`

**Rectangle Sum Formula**:
```
Sum = SAT[x2,y2] - SAT[x2,y1-1] - SAT[x1-1,y2] + SAT[x1-1,y1-1]
```

**When to Use**:
- Many rectangle/square sum queries on same grid
- Finding optimal rectangle/square by size
- 2D range sum queries
- Computing multiple overlapping areas

**Performance**:
- Preprocessing: O(N × M) for grid of size N×M
- Each query: O(1)
- Total for all queries: O(N × M) + O(Q) instead of O(N × M × Q)

**Alternative Names**: Integral Image (computer vision), Prefix Sum 2D

## Common Grid Algorithms
- **Flood Fill**: DFS/BFS to find connected regions
- **Pathfinding**: BFS for shortest path, Dijkstra/A* for weighted
- **Pattern Matching**: Find specific shapes or arrangements
- **Cellular Automaton**: Update all cells based on neighbor states
- **Ray Casting**: Shoot rays to detect intersections (2023 Day 10)
- **Summed Area Table**: O(1) rectangle sum queries after O(N²) preprocessing
