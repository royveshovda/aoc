import AOC

aoc 2024, 10 do
  @moduledoc """
  https://adventofcode.com/2024/day/10
  """

  def p1(input) do
    grid = Utils.Grid.input_to_map(input, &String.to_integer/1)
    starts = grid |> Enum.filter(fn {_pos, v} -> v == 0 end)

    starts
    |> Enum.map(fn {pos, value} -> next_step_p1(grid, pos, value) end)
    |> Enum.map(fn x -> Enum.count(x) end)
    |> Enum.sum()
  end

  def next_step_p1(_grid, pos, 9), do: [pos]

  def next_step_p1(grid, pos, value) do
    #IO.inspect("Step at #{inspect(pos)} with value #{value}")
    {x, y} = pos
    p1 = {x + 1, y}
    p2 = {x - 1, y}
    p3 = {x, y + 1}
    p4 = {x, y - 1}

    [p1, p2, p3, p4]
    |> Enum.map(fn p -> {p, grid[p]} end)
    |> Enum.filter(fn {_p, v} -> v == value + 1 end)
    |> Enum.flat_map(fn {p, v} -> next_step_p1(grid, p, v) end)
    |> Enum.uniq()
  end

  def next_step_p2(_grid, _pos, 9), do: 1

  def next_step_p2(grid, pos, value) do
    #IO.inspect("Step at #{inspect(pos)} with value #{value}")
    {x, y} = pos
    p1 = {x + 1, y}
    p2 = {x - 1, y}
    p3 = {x, y + 1}
    p4 = {x, y - 1}

    [p1, p2, p3, p4]
    |> Enum.map(fn p -> {p, grid[p]} end)
    #|> IO.inspect()
    |> Enum.filter(fn {_p, v} -> v == value + 1 end)
    |> Enum.map(fn {p, v} -> next_step_p2(grid, p, v) end)
    |> Enum.sum()
  end

  def p2(input) do
    grid = Utils.Grid.input_to_map(input, &String.to_integer/1)
    starts = grid |> Enum.filter(fn {_pos, v} -> v == 0 end)

    starts
    |> Enum.map(fn {pos, value} -> next_step_p2(grid, pos, value) end)
    |> Enum.sum()
  end
end
