import AOC

aoc 2019, 24 do
  @moduledoc """
  https://adventofcode.com/2019/day/24

  Day 24: Planet of Discord - Game of Life variant on a 5x5 grid.
  Part 1: Find first repeated layout, calculate biodiversity rating.
  Part 2: Recursive grids - center tile is portal to inner level.
  """

  @doc """
  Part 1: Find first layout that appears twice and calculate biodiversity rating.

      iex> p1(example_string(0))
      2129920
  """
  def p1(input) do
    grid = parse(input)
    find_repeated(grid, MapSet.new())
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _x} -> c == "#" end)
      |> Enum.map(fn {_c, x} -> {x, y} end)
    end)
    |> MapSet.new()
  end

  defp find_repeated(grid, seen) do
    if MapSet.member?(seen, grid) do
      biodiversity(grid)
    else
      find_repeated(step(grid), MapSet.put(seen, grid))
    end
  end

  defp step(grid) do
    # Check all 25 cells
    for x <- 0..4, y <- 0..4, should_have_bug?(grid, x, y), into: MapSet.new() do
      {x, y}
    end
  end

  defp should_have_bug?(grid, x, y) do
    neighbors = count_neighbors(grid, x, y)
    has_bug = MapSet.member?(grid, {x, y})

    cond do
      has_bug and neighbors == 1 -> true
      not has_bug and neighbors in [1, 2] -> true
      true -> false
    end
  end

  defp count_neighbors(grid, x, y) do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
    |> Enum.count(fn {dx, dy} ->
      nx = x + dx
      ny = y + dy
      nx >= 0 and nx <= 4 and ny >= 0 and ny <= 4 and MapSet.member?(grid, {nx, ny})
    end)
  end

  defp biodiversity(grid) do
    grid
    |> Enum.map(fn {x, y} ->
      pos = y * 5 + x
      :math.pow(2, pos) |> round()
    end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Recursive grids - simulate for 200 minutes, count total bugs.
  Center tile (2,2) is a portal to inner level.

      iex> p2(example_string(0), 10)
      99
  """
  def p2(input, minutes \\ 200) do
    grid = parse(input)
    # Store as {x, y, level} where level 0 is the starting level
    initial = grid |> Enum.map(fn {x, y} -> {x, y, 0} end) |> MapSet.new()

    1..minutes
    |> Enum.reduce(initial, fn _, g -> step_recursive(g) end)
    |> MapSet.size()
  end

  defp step_recursive(grid) do
    # Determine range of levels to check (existing levels +/- 1)
    levels = grid |> Enum.map(fn {_x, _y, level} -> level end)
    {min_level, max_level} = if Enum.empty?(levels), do: {0, 0}, else: Enum.min_max(levels)

    # Check all cells in all relevant levels
    for level <- (min_level - 1)..(max_level + 1),
        x <- 0..4,
        y <- 0..4,
        {x, y} != {2, 2},  # Center tile is recursive portal, never has bugs
        should_have_bug_recursive?(grid, x, y, level),
        into: MapSet.new() do
      {x, y, level}
    end
  end

  defp should_have_bug_recursive?(grid, x, y, level) do
    neighbors = count_neighbors_recursive(grid, x, y, level)
    has_bug = MapSet.member?(grid, {x, y, level})

    cond do
      has_bug and neighbors == 1 -> true
      not has_bug and neighbors in [1, 2] -> true
      true -> false
    end
  end

  defp count_neighbors_recursive(grid, x, y, level) do
    get_recursive_neighbors(x, y, level)
    |> Enum.count(fn {nx, ny, nl} -> MapSet.member?(grid, {nx, ny, nl}) end)
  end

  # Get all neighbors for a cell, including recursive neighbors
  defp get_recursive_neighbors(x, y, level) do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
    |> Enum.flat_map(fn {dx, dy} ->
      nx = x + dx
      ny = y + dy
      get_neighbor_cells(nx, ny, level, dx, dy)
    end)
  end

  # Handle neighbor at position (nx, ny) from direction (dx, dy)
  defp get_neighbor_cells(nx, ny, level, dx, dy) do
    cond do
      # Going to center (2,2) - goes to inner level (level + 1)
      {nx, ny} == {2, 2} ->
        inner_edge_cells(dx, dy, level + 1)

      # Going off grid - goes to outer level (level - 1)
      nx < 0 -> [{1, 2, level - 1}]  # Left edge -> (1,2) of outer
      nx > 4 -> [{3, 2, level - 1}]  # Right edge -> (3,2) of outer
      ny < 0 -> [{2, 1, level - 1}]  # Top edge -> (2,1) of outer
      ny > 4 -> [{2, 3, level - 1}]  # Bottom edge -> (2,3) of outer

      # Normal neighbor on same level
      true -> [{nx, ny, level}]
    end
  end

  # When going into center, get all 5 cells on the appropriate edge of inner level
  defp inner_edge_cells(dx, dy, inner_level) do
    cond do
      # Coming from left (dx=1) -> left column of inner (x=0)
      dx == 1 -> for y <- 0..4, do: {0, y, inner_level}
      # Coming from right (dx=-1) -> right column of inner (x=4)
      dx == -1 -> for y <- 0..4, do: {4, y, inner_level}
      # Coming from above (dy=1) -> top row of inner (y=0)
      dy == 1 -> for x <- 0..4, do: {x, 0, inner_level}
      # Coming from below (dy=-1) -> bottom row of inner (y=4)
      dy == -1 -> for x <- 0..4, do: {x, 4, inner_level}
    end
  end
end
