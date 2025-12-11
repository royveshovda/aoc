import AOC

aoc 2017, 22 do
  @moduledoc """
  https://adventofcode.com/2017/day/22
  """

  def p1(input) do
    grid = parse(input)
    {_grid, _pos, _dir, infections} = run_bursts(grid, 10_000, false)
    infections
  end

  def p2(input) do
    grid = parse(input)
    {_grid, _pos, _dir, infections} = run_bursts(grid, 10_000_000, true)
    infections
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    size = length(lines)
    center = div(size, 2)

    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _col} -> char == "#" end)
      |> Enum.map(fn {_char, col} ->
        {{col - center, row - center}, :infected}
      end)
    end)
    |> Map.new()
  end

  defp run_bursts(grid, count, evolved) do
    Enum.reduce(1..count, {grid, {0, 0}, {0, -1}, 0}, fn _, {grid, pos, dir, infections} ->
      burst(grid, pos, dir, infections, evolved)
    end)
  end

  defp burst(grid, pos, dir, infections, evolved) do
    state = Map.get(grid, pos, :clean)

    {new_dir, new_state, new_infections} =
      if evolved do
        case state do
          :clean -> {turn_left(dir), :weakened, infections}
          :weakened -> {dir, :infected, infections + 1}
          :infected -> {turn_right(dir), :flagged, infections}
          :flagged -> {reverse(dir), :clean, infections}
        end
      else
        case state do
          :infected -> {turn_right(dir), :clean, infections}
          :clean -> {turn_left(dir), :infected, infections + 1}
        end
      end

    new_grid =
      if new_state == :clean do
        Map.delete(grid, pos)
      else
        Map.put(grid, pos, new_state)
      end

    new_pos = move(pos, new_dir)
    {new_grid, new_pos, new_dir, new_infections}
  end

  defp turn_left({dx, dy}), do: {dy, -dx}
  defp turn_right({dx, dy}), do: {-dy, dx}
  defp reverse({dx, dy}), do: {-dx, -dy}

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}
end
