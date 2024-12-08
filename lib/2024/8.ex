import AOC

aoc 2024, 8 do
  @moduledoc """
  https://adventofcode.com/2024/day/8
  """

  @doc """
      iex> p1(example_string())
  """
  def p1(input) do
    {grid, {min_x..max_x//1, min_y..max_y//1}} = Utils.Grid.input_to_map_with_bounds(input)

    antennas = Enum.filter(grid, fn {_, t} -> t != "." end)

    pairs =
      for {pos1, val1} <- antennas, {pos2, val2} <- antennas, pos1 != pos2 and val1 == val2, do: {pos1, pos2}

    pairs
    |> Enum.flat_map(&create_antinodes/1)
    |> Enum.uniq()
    |> Enum.reject(fn {x, y} -> x < min_x || x > max_x || y < min_y || y > max_y end)
    |> Enum.count()
  end

  def create_antinodes({{x1, y1}, {x2, y2}}) do
    dx = x2 - x1
    dy = y2 - y1
    [{x1 - dx, y1 - dy}, {x2 + dx, y2 + dy}]
  end

  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    {grid, {min_x..max_x//1, min_y..max_y//1}} = Utils.Grid.input_to_map_with_bounds(input)

    antennas = Enum.filter(grid, fn {_, t} -> t != "." end)

    pairs =
      for {pos1, val1} <- antennas, {pos2, val2} <- antennas, pos1 != pos2 and val1 == val2, do: {pos1, pos2}

    pairs
    |> Enum.flat_map(fn x -> create_all_antinodes(x, {{min_x, min_y},{max_x, max_y}}) end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def create_all_antinodes({{x1, y1}, {x2, y2}}, {{min_x, min_y},{max_x, max_y}}) do
    dx = x2 - x1
    dy = y2 - y1

    # generate values up by starting on {x1,y1} and substracting dx,dy until we reach the bounds
    up =
      Stream.iterate({x1, y1}, fn {x, y} -> {x - dx, y - dy} end)
      |> Stream.take_while(fn {x, y} -> x >= min_x and y >= min_y and x <= max_x and y <= max_y end)
      |> Enum.to_list()

    down =
      Stream.iterate({x2, y2}, fn {x, y} -> {x + dx, y + dy} end)
      |> Stream.take_while(fn {x, y} -> x >= min_x and y >= min_y and x <= max_x and y <= max_y end)
      |> Enum.to_list()

    up ++ down ++ [{x1, y1}, {x2, y2}]
  end
end
