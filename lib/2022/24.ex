# Inspired from https://github.com/ypisetsky/advent-of-code-2022/blob/main/lib/days/day24.ex

import AOC

aoc 2022, 24 do
  def p1(input) do
    lines =
      input
      |> String.split("\n")

    width = String.length(List.first(lines)) - 2
    height = Enum.count(lines) - 2

    grid =
      lines
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)
      |> List.flatten()

    {step1, _grid} = walk(1, [{-1, 0}], grid, width, height, {height - 1, width - 1})
    # step the grid while the player walks the 1 step to the exit

    step1
  end

  def parse_line({line, row}) do
    line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.map(&parse_char(&1, row))
      |> Enum.reject(&is_nil/1)
  end

  def parse_char({ch, col}, row) do
    case ch do
      ?> -> {row - 1, col - 1, 0, 1}
      ?< -> {row - 1, col - 1, 0, -1}
      ?^ -> {row - 1, col - 1, -1, 0}
      ?v -> {row - 1, col - 1, 1, 0}
      _ -> nil
    end
  end

  def walk(step, player_locations, grid, width, height, target) do
    if target in player_locations do
      {step, grid}
    else
      new_grid = Enum.map(grid, &translate(&1, width, height))
      new_grid_points = Enum.map(new_grid, fn {x, y, _, _} -> {x, y} end) |> MapSet.new()
      new_player_locations =
        player_locations
        |> Enum.map(&neighbors4(&1, width, height))
        |> List.flatten()
        |> Enum.reject(&MapSet.member?(new_grid_points, &1))
        |> Enum.uniq()

      if new_player_locations == [] do
        raise "no player locations!"
      end

      walk(step + 1, new_player_locations, new_grid, width, height, target)
    end
  end

  def neighbors4({x, y}, width, height) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1},
      {x, y}
    ] |> Enum.filter(&valid_pos(&1, width, height))
  end

  def valid_pos({-1, 0}, _width, _height), do: true
  def valid_pos({height, wm1}, width, height) when width - 1 == wm1, do: true
  def valid_pos({x, y}, _, _) when x < 0 when y < 0, do: false
  def valid_pos({x, y}, width, height) when x >= height when y >= width, do: false
  def valid_pos(_, _, _), do: true

  def translate({x, y, dx, dy}, width, height) do
    {rem(height + x + dx, height), rem(width + y + dy, width), dx, dy}
  end

  def step_grid(grid, width, height) do
    Enum.map(grid, &translate(&1, width, height))
  end

  def p2(input) do
    lines =
      input
      |> String.split("\n")

    width = String.length(List.first(lines)) - 2
    height = Enum.count(lines) - 2

    grid =
      lines
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)
      |> List.flatten()

      {step1, grid} = walk(1, [{-1, 0}], grid, width, height, {height - 1, width - 1})

      grid = step_grid(grid, width, height)
      {step2, grid} = walk(step1 + 1, [{height, width - 1}], grid, width, height, {0, 0})

      grid = step_grid(grid, width, height)
      {step3, _grid} = walk(step2 + 1, [{-1, 0}], grid, width, height, {height - 1, width - 1})

      step3
  end
end
