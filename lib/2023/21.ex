import AOC

aoc 2023, 21 do
  @moduledoc """
  https://adventofcode.com/2023/day/21

  P2 copied from: https://github.com/mathsaey/adventofcode/blob/master/lib/2023/21.ex
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

      iex> p2(input_string())
      123
  """
  def p2(input) do
    {start, rocks, size} = input |> parse() |> add_negative_rocks()
    rocks = rocks_stream({start, rocks, size})

    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(&{&1, (div(size, 2) + &1 * size)})
    |> Stream.map(fn {idx, steps} -> {idx, Enum.at(rocks, steps)} end)
    |> Enum.take(3)
    |> then(fn tups -> apply(&lagrange/3, tups) end)
    |> apply([202300])
  end

  def lagrange({x0, y0}, {x1, y1}, {x2, y2}) do
    fn x ->
      t0 = div((x - x1) * (x - x2), (x0 - x1) * (x0 - x2)) * y0
      t1 = div((x - x0) * (x - x2), (x1 - x0) * (x1 - x2)) * y1
      t2 = div((x - x0) * (x - x1), (x2 - x0) * (x2 - x1)) * y2
      t0 + t1 + t2
    end
  end

  def rocks_stream({start, rocks, size}) do
    [start]
    |> Stream.iterate(&next(&1, rocks, size))
    |> Stream.map(&length/1)
  end

  def next(positions, rocks, size) do
    positions
    |> Enum.flat_map(&neighbours(&1, rocks, size))
    |> Enum.uniq()
  end

  def neighbours({x, y}, rocks, size) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.reject(fn {x, y} -> {rem(x, size), rem(y, size)} in rocks end)
  end

  def parse_input(input) do
    input
    |> Utils.Grid.input_to_map_with_bounds()
  end

  def parse(input) do
    {grid, {xrange, _}} = Utils.Grid.input_to_map_with_bounds(input)
    {start, _} = Enum.find(grid, fn {_, v} -> v == "S" end)
    rocks = grid |> Enum.filter(fn {_, v} -> v == "#" end) |> MapSet.new(&elem(&1, 0))
    {start, rocks, Range.size(xrange)}
  end

  def add_negative_rocks({start, rocks, size}) do
    rocks
    |> Enum.flat_map(fn {x, y} -> [{x - size, y - size}, {x - size, y}, {x, y - size}] end)
    |> Enum.concat(rocks)
    |> MapSet.new()
    |> then(fn rocks -> {start, rocks, size} end)
  end
end
