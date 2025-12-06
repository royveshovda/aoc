import AOC

aoc 2021, 25 do
  @moduledoc """
  Day 25: Sea Cucumber

  Simulate sea cucumber herds on toroidal grid.
  East-facing (>) move first (all simultaneously), then south-facing (v).
  Find when movement stops.
  """

  @doc """
  Part 1: Find the first step where no sea cucumber moves.
  """
  def p1(input) do
    {grid, width, height} = parse(input)
    find_stable(grid, width, height, 1)
  end

  @doc """
  Part 2: Day 25 has no Part 2 (just get all other stars).
  """
  def p2(_input) do
    # Day 25 Part 2 is automatic when you have all other stars
    "⭐"
  end

  defp find_stable(grid, width, height, step) do
    {new_grid, moved?} = simulate_step(grid, width, height)

    if moved? do
      find_stable(new_grid, width, height, step + 1)
    else
      step
    end
  end

  defp simulate_step(grid, width, height) do
    # Move east-facing first
    {grid, moved_east?} = move_east(grid, width, height)
    # Then move south-facing
    {grid, moved_south?} = move_south(grid, width, height)

    {grid, moved_east? or moved_south?}
  end

  defp move_east(grid, width, _height) do
    east_cucumbers =
      grid
      |> Enum.filter(fn {_pos, val} -> val == ?> end)
      |> Enum.map(fn {{x, y}, _} -> {x, y} end)

    # Determine which can move BEFORE moving any (simultaneous movement)
    moves =
      east_cucumbers
      |> Enum.filter(fn {x, y} ->
        new_x = rem(x + 1, width)
        Map.get(grid, {new_x, y}) == nil
      end)
      |> Enum.map(fn {x, y} -> {{x, y}, {rem(x + 1, width), y}} end)

    new_grid =
      Enum.reduce(moves, grid, fn {{old_x, old_y}, {new_x, new_y}}, g ->
        g
        |> Map.delete({old_x, old_y})
        |> Map.put({new_x, new_y}, ?>)
      end)

    {new_grid, moves != []}
  end

  defp move_south(grid, _width, height) do
    south_cucumbers =
      grid
      |> Enum.filter(fn {_pos, val} -> val == ?v end)
      |> Enum.map(fn {{x, y}, _} -> {x, y} end)

    # Determine which can move BEFORE moving any (simultaneous movement)
    moves =
      south_cucumbers
      |> Enum.filter(fn {x, y} ->
        new_y = rem(y + 1, height)
        Map.get(grid, {x, new_y}) == nil
      end)
      |> Enum.map(fn {x, y} -> {{x, y}, {x, rem(y + 1, height)}} end)

    new_grid =
      Enum.reduce(moves, grid, fn {{old_x, old_y}, {new_x, new_y}}, g ->
        g
        |> Map.delete({old_x, old_y})
        |> Map.put({new_x, new_y}, ?v)
      end)

    {new_grid, moves != []}
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    height = length(lines)
    width = String.length(hd(lines))

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {?., _x} -> []
          {char, x} -> [{{x, y}, char}]
        end)
      end)
      |> Map.new()

    {grid, width, height}
  end
end
