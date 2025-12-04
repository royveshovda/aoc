import AOC

aoc 2015, 18 do
  @moduledoc """
  https://adventofcode.com/2015/day/18

  Day 18: Like a GIF For Your Yard

  Conway's Game of Life variant with specific rules:
  - A light ON stays on when 2 or 3 neighbors are on, turns off otherwise
  - A light OFF turns on if exactly 3 neighbors are on, stays off otherwise
  """

  def p1(input, steps \\ 100) do
    grid = parse_input(input)

    1..steps
    |> Enum.reduce(grid, fn _, current_grid ->
      animate_step(current_grid, false)
    end)
    |> count_lights_on()
  end

  def p2(input, steps \\ 100) do
    grid = parse_input(input)

    # Turn on corner lights
    grid = turn_on_corners(grid)

    1..steps
    |> Enum.reduce(grid, fn _, current_grid ->
      animate_step(current_grid, true)
    end)
    |> count_lights_on()
  end

  defp parse_input(input) do
    lines = String.split(input, "\n", trim: true)

    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char == "#"} end)
    end)
    |> Map.new()
  end

  defp animate_step(grid, stuck_corners) do
    grid
    |> Enum.map(fn {{x, y} = pos, is_on} ->
      neighbors_on = count_neighbors_on(grid, x, y)

      new_state = cond do
        is_on and neighbors_on in [2, 3] -> true
        not is_on and neighbors_on == 3 -> true
        true -> false
      end

      {pos, new_state}
    end)
    |> Map.new()
    |> then(fn new_grid ->
      if stuck_corners, do: turn_on_corners(new_grid), else: new_grid
    end)
  end

  defp count_neighbors_on(grid, x, y) do
    [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]
    |> Enum.count(fn pos -> Map.get(grid, pos, false) end)
  end

  defp turn_on_corners(grid) do
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    grid
    |> Map.put({0, 0}, true)
    |> Map.put({max_x, 0}, true)
    |> Map.put({0, max_y}, true)
    |> Map.put({max_x, max_y}, true)
  end

  defp count_lights_on(grid) do
    grid
    |> Enum.count(fn {_pos, is_on} -> is_on end)
  end
end
