import AOC

aoc 2022, 8 do
  @moduledoc """
  Day 8: Treetop Tree House

  Grid of tree heights.
  Part 1: Count trees visible from outside.
  Part 2: Find tree with highest scenic score.
  """

  @doc """
  Part 1: Count trees visible from outside the grid.

  ## Examples

      iex> example = "30373\\n25512\\n65332\\n33549\\n35390"
      iex> p1(example)
      21
  """
  def p1(input) do
    grid = parse(input)
    {max_x, max_y} = grid |> Map.keys() |> Enum.max()

    grid
    |> Map.keys()
    |> Enum.count(fn pos -> visible?(grid, pos, max_x, max_y) end)
  end

  @doc """
  Part 2: Find highest scenic score (product of viewing distances).

  ## Examples

      iex> example = "30373\\n25512\\n65332\\n33549\\n35390"
      iex> p2(example)
      8
  """
  def p2(input) do
    grid = parse(input)
    {max_x, max_y} = grid |> Map.keys() |> Enum.max()

    grid
    |> Map.keys()
    |> Enum.map(fn pos -> scenic_score(grid, pos, max_x, max_y) end)
    |> Enum.max()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, String.to_integer(c)} end)
    end)
    |> Map.new()
  end

  defp visible?(grid, {x, y}, max_x, max_y) do
    # Edge trees are always visible
    if x == 0 or y == 0 or x == max_x or y == max_y do
      true
    else
      height = grid[{x, y}]
      # Check all 4 directions
      left = Enum.all?(0..(x - 1), fn x2 -> grid[{x2, y}] < height end)
      right = Enum.all?((x + 1)..max_x, fn x2 -> grid[{x2, y}] < height end)
      up = Enum.all?(0..(y - 1), fn y2 -> grid[{x, y2}] < height end)
      down = Enum.all?((y + 1)..max_y, fn y2 -> grid[{x, y2}] < height end)

      left or right or up or down
    end
  end

  defp scenic_score(grid, {x, y}, max_x, max_y) do
    height = grid[{x, y}]

    # Edge trees will have 0 in at least one direction
    left = if x == 0, do: 0, else: view_distance((x - 1)..0//-1, fn x2 -> grid[{x2, y}] end, height)
    right = if x == max_x, do: 0, else: view_distance((x + 1)..max_x//1, fn x2 -> grid[{x2, y}] end, height)
    up = if y == 0, do: 0, else: view_distance((y - 1)..0//-1, fn y2 -> grid[{x, y2}] end, height)
    down = if y == max_y, do: 0, else: view_distance((y + 1)..max_y//1, fn y2 -> grid[{x, y2}] end, height)

    left * right * up * down
  end

  defp view_distance(range, get_height, our_height) do
    range
    |> Enum.reduce_while(0, fn pos, count ->
      tree_height = get_height.(pos)

      if tree_height >= our_height do
        {:halt, count + 1}
      else
        {:cont, count + 1}
      end
    end)
  end
end
