import AOC

aoc 2024, 15 do
  @moduledoc """
  https://adventofcode.com/2024/day/15

  Warehouse Woes - Sokoban-style pushing.
  P1: Normal boxes, push chains.
  P2: Wide boxes (2 cells), complex vertical pushes.
  """

  def p1(input) do
    {grid, moves, robot} = parse(input)
    grid = simulate(grid, moves, robot)

    grid
    |> Enum.filter(fn {_pos, c} -> c == "O" end)
    |> Enum.map(fn {{x, y}, _c} -> 100 * y + x end)
    |> Enum.sum()
  end

  def p2(input) do
    {grid, moves, robot} = parse(input)
    {grid, robot} = widen(grid, robot)
    grid = simulate_wide(grid, moves, robot)

    grid
    |> Enum.filter(fn {_pos, c} -> c == "[" end)
    |> Enum.map(fn {{x, y}, _c} -> 100 * y + x end)
    |> Enum.sum()
  end

  defp parse(input) do
    [grid_str, moves_str] = String.split(input, "\n\n", trim: true)

    {grid, robot} =
      grid_str
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, nil}, fn {row, y}, {g, r} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce({g, r}, fn {c, x}, {g2, r2} ->
          pos = {x, y}

          case c do
            "@" -> {Map.put(g2, pos, "."), pos}
            _ -> {Map.put(g2, pos, c), r2}
          end
        end)
      end)

    moves =
      moves_str
      |> String.replace("\n", "")
      |> String.graphemes()

    {grid, moves, robot}
  end

  defp simulate(grid, [], _robot), do: grid

  defp simulate(grid, [move | rest], robot) do
    {dx, dy} = dir(move)
    {rx, ry} = robot
    next = {rx + dx, ry + dy}

    case Map.get(grid, next) do
      "#" ->
        simulate(grid, rest, robot)

      "." ->
        simulate(grid, rest, next)

      "O" ->
        # Find end of box chain
        case find_empty_p1(grid, next, {dx, dy}) do
          nil ->
            simulate(grid, rest, robot)

          empty_pos ->
            # Move box chain
            grid =
              grid
              |> Map.put(next, ".")
              |> Map.put(empty_pos, "O")

            simulate(grid, rest, next)
        end
    end
  end

  defp find_empty_p1(grid, {x, y}, {dx, dy}) do
    next = {x + dx, y + dy}

    case Map.get(grid, next) do
      "#" -> nil
      "." -> next
      "O" -> find_empty_p1(grid, next, {dx, dy})
    end
  end

  defp widen(grid, {rx, ry}) do
    wide_grid =
      grid
      |> Enum.flat_map(fn {{x, y}, c} ->
        case c do
          "#" -> [{{x * 2, y}, "#"}, {{x * 2 + 1, y}, "#"}]
          "O" -> [{{x * 2, y}, "["}, {{x * 2 + 1, y}, "]"}]
          "." -> [{{x * 2, y}, "."}, {{x * 2 + 1, y}, "."}]
        end
      end)
      |> Map.new()

    {wide_grid, {rx * 2, ry}}
  end

  defp simulate_wide(grid, [], _robot), do: grid

  defp simulate_wide(grid, [move | rest], robot) do
    {dx, dy} = dir(move)
    {rx, ry} = robot
    next = {rx + dx, ry + dy}

    case Map.get(grid, next) do
      "#" ->
        simulate_wide(grid, rest, robot)

      "." ->
        simulate_wide(grid, rest, next)

      box when box in ["[", "]"] ->
        # Horizontal: simple chain
        if dy == 0 do
          case find_empty_wide_h(grid, next, dx) do
            nil ->
              simulate_wide(grid, rest, robot)

            empty_pos ->
              grid = shift_horizontal(grid, next, empty_pos, dx)
              simulate_wide(grid, rest, next)
          end
        else
          # Vertical: need to track all connected boxes
          boxes = collect_boxes_vertical(grid, next, dy)

          if can_push_vertical(grid, boxes, dy) do
            grid = push_vertical(grid, boxes, dy)
            simulate_wide(grid, rest, next)
          else
            simulate_wide(grid, rest, robot)
          end
        end
    end
  end

  defp find_empty_wide_h(grid, {x, y}, dx) do
    next = {x + dx, y}

    case Map.get(grid, next) do
      "#" -> nil
      "." -> next
      c when c in ["[", "]"] -> find_empty_wide_h(grid, next, dx)
    end
  end

  defp shift_horizontal(grid, {sx, sy}, {ex, _ey}, dx) do
    # Shift all cells from sx to ex by dx
    range = if dx > 0, do: ex..sx, else: ex..sx

    Enum.reduce(range, grid, fn x, g ->
      Map.put(g, {x, sy}, Map.get(g, {x - dx, sy}))
    end)
    |> Map.put({sx, sy}, ".")
  end

  defp collect_boxes_vertical(grid, pos, dy) do
    do_collect([pos], grid, dy, MapSet.new())
  end

  defp do_collect([], _grid, _dy, boxes), do: boxes

  defp do_collect([{x, y} | rest], grid, dy, boxes) do
    c = Map.get(grid, {x, y})

    {left, right} =
      case c do
        "[" -> {{x, y}, {x + 1, y}}
        "]" -> {{x - 1, y}, {x, y}}
        _ -> {nil, nil}
      end

    if left == nil or MapSet.member?(boxes, left) do
      do_collect(rest, grid, dy, boxes)
    else
      boxes = boxes |> MapSet.put(left) |> MapSet.put(right)
      # Check cells below/above both halves
      next_left = {elem(left, 0), y + dy}
      next_right = {elem(right, 0), y + dy}
      new_cells = [next_left, next_right] |> Enum.filter(fn p -> Map.get(grid, p) in ["[", "]"] end)
      do_collect(new_cells ++ rest, grid, dy, boxes)
    end
  end

  defp can_push_vertical(grid, boxes, dy) do
    # Check if all boxes can move dy
    boxes
    |> Enum.all?(fn {x, y} ->
      target = {x, y + dy}
      t = Map.get(grid, target)
      t != "#"
    end)
  end

  defp push_vertical(grid, boxes, dy) do
    # Sort by y (push from far end first)
    sorted =
      boxes
      |> Enum.sort_by(fn {_x, y} -> y * -dy end)

    Enum.reduce(sorted, grid, fn {x, y}, g ->
      c = Map.get(g, {x, y})
      g |> Map.put({x, y + dy}, c) |> Map.put({x, y}, ".")
    end)
  end

  defp dir("^"), do: {0, -1}
  defp dir("v"), do: {0, 1}
  defp dir("<"), do: {-1, 0}
  defp dir(">"), do: {1, 0}
end
