import AOC

aoc 2023, 21 do
  @moduledoc """
  https://adventofcode.com/2023/day/21
  """

  @doc """
      iex> p1(example_string(), 6)
      16

      iex> p1(input_string())
      3795
  """
  def p1(input, steps_to_take \\ 64) do
    {grid, _bounds} =
      input
      |> parse_input()

    start =
      grid
      |> Enum.find(fn {_, v} -> v == "S" end)
      |> then(fn {{x, y}, _} -> {x, y} end)

    step(grid, [start], steps_to_take)
    |> Enum.count()


  end

  def step(_grid, edge, 0), do: edge

  def step(grid, edge, steps_left) do
    IO.inspect(steps_left)
    new_edge =
      edge
      |> Enum.flat_map(fn pos -> neighbours(grid, pos) end)
      |> Enum.uniq()
      |> Enum.reject(fn pos -> pos in edge end)

    step(grid, new_edge, steps_left - 1)
    #step(grid, visited ++ new_edge, new_edge, steps_left - 1)
  end

  def neighbours(grid, {x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(fn {x, y} -> Map.get(grid, {x, y}) != "#" end)
    |> Enum.filter(fn pos -> pos in Map.keys(grid) end)
  end


  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse_input()
  end

  def parse_input(input) do
    input
    |> Utils.Grid.input_to_map_with_bounds()
  end
end
