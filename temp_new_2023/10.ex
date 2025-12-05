import AOC

aoc 2023, 10 do
  @moduledoc """
  https://adventofcode.com/2023/day/10

  Pipe maze. Part 1: find farthest point from start.
  Part 2: count tiles enclosed by the loop.
  """

  @doc """
      iex> p1(example_string())
      4

      iex> p1(input_string())
      6875
  """
  def p1(input) do
    {grid, start} = parse(input)
    loop = find_loop(grid, start)
    div(length(loop), 2)
  end

  @doc """
      iex> p2(example_string())
      1

      iex> p2(input_string())
      471
  """
  def p2(input) do
    {grid, start} = parse(input)
    loop = find_loop(grid, start)
    loop_set = MapSet.new(loop)

    # Use ray casting - count crossings from left
    {max_row, max_col} = grid |> Map.keys() |> Enum.reduce({0, 0}, fn {r, c}, {mr, mc} ->
      {max(r, mr), max(c, mc)}
    end)

    # Replace S with actual pipe type for proper crossing detection
    grid = replace_start(grid, start, loop)

    for r <- 0..max_row, c <- 0..max_col do
      {r, c}
    end
    |> Enum.count(fn pos ->
      not MapSet.member?(loop_set, pos) and inside?(grid, loop_set, pos, max_col)
    end)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, c} -> {{r, c}, char} end)
      end)
      |> Map.new()

    start = Enum.find_value(grid, fn {pos, char} -> if char == "S", do: pos end)
    {grid, start}
  end

  defp find_loop(grid, start) do
    # Find two valid directions from start
    {r, c} = start
    neighbors = [
      {{r - 1, c}, :north}, {{r + 1, c}, :south},
      {{r, c - 1}, :west}, {{r, c + 1}, :east}
    ]

    valid_starts = Enum.filter(neighbors, fn {pos, dir} ->
      pipe = Map.get(grid, pos, ".")
      connects?(pipe, opposite(dir))
    end)

    # Pick first valid direction and follow the loop
    # came_from is the direction from the pipe's perspective (opposite of how we moved)
    [{next_pos, dir} | _] = valid_starts
    follow_loop(grid, start, next_pos, opposite(dir), [start])
  end

  defp follow_loop(_grid, start, start, _came_from, path), do: path
  defp follow_loop(grid, start, current, came_from, path) do
    pipe = Map.get(grid, current)
    next_dir = next_direction(pipe, came_from)
    next_pos = move(current, next_dir)
    follow_loop(grid, start, next_pos, opposite(next_dir), [current | path])
  end

  defp connects?("|", dir) when dir in [:north, :south], do: true
  defp connects?("-", dir) when dir in [:east, :west], do: true
  defp connects?("L", dir) when dir in [:north, :east], do: true
  defp connects?("J", dir) when dir in [:north, :west], do: true
  defp connects?("7", dir) when dir in [:south, :west], do: true
  defp connects?("F", dir) when dir in [:south, :east], do: true
  defp connects?(_, _), do: false

  defp next_direction("|", :north), do: :south
  defp next_direction("|", :south), do: :north
  defp next_direction("-", :east), do: :west
  defp next_direction("-", :west), do: :east
  defp next_direction("L", :north), do: :east
  defp next_direction("L", :east), do: :north
  defp next_direction("J", :north), do: :west
  defp next_direction("J", :west), do: :north
  defp next_direction("7", :south), do: :west
  defp next_direction("7", :west), do: :south
  defp next_direction("F", :south), do: :east
  defp next_direction("F", :east), do: :south

  defp opposite(:north), do: :south
  defp opposite(:south), do: :north
  defp opposite(:east), do: :west
  defp opposite(:west), do: :east

  defp move({r, c}, :north), do: {r - 1, c}
  defp move({r, c}, :south), do: {r + 1, c}
  defp move({r, c}, :east), do: {r, c + 1}
  defp move({r, c}, :west), do: {r, c - 1}

  defp replace_start(grid, {r, c} = start, loop) do
    # Determine what pipe S should be based on connected neighbors in loop
    loop_set = MapSet.new(loop)
    north = MapSet.member?(loop_set, {r - 1, c}) and connects?(Map.get(grid, {r - 1, c}, "."), :south)
    south = MapSet.member?(loop_set, {r + 1, c}) and connects?(Map.get(grid, {r + 1, c}, "."), :north)
    east = MapSet.member?(loop_set, {r, c + 1}) and connects?(Map.get(grid, {r, c + 1}, "."), :west)
    west = MapSet.member?(loop_set, {r, c - 1}) and connects?(Map.get(grid, {r, c - 1}, "."), :east)

    pipe = case {north, south, east, west} do
      {true, true, false, false} -> "|"
      {false, false, true, true} -> "-"
      {true, false, true, false} -> "L"
      {true, false, false, true} -> "J"
      {false, true, false, true} -> "7"
      {false, true, true, false} -> "F"
    end

    Map.put(grid, start, pipe)
  end

  defp inside?(grid, loop_set, {r, c}, max_col) do
    # Ray cast to the right, count vertical crossings
    # | counts as 1, L--7 counts as 1, F--J counts as 1
    # L--J and F--7 count as 0 (same side)
    crossings =
      (c + 1)..max_col
      |> Enum.filter(&MapSet.member?(loop_set, {r, &1}))
      |> Enum.map(&Map.get(grid, {r, &1}))
      |> count_crossings()

    rem(crossings, 2) == 1
  end

  defp count_crossings(pipes) do
    count_crossings(pipes, nil, 0)
  end

  defp count_crossings([], _, count), do: count
  defp count_crossings(["|" | rest], _, count), do: count_crossings(rest, nil, count + 1)
  defp count_crossings(["-" | rest], corner, count), do: count_crossings(rest, corner, count)
  defp count_crossings(["L" | rest], _, count), do: count_crossings(rest, "L", count)
  defp count_crossings(["F" | rest], _, count), do: count_crossings(rest, "F", count)
  defp count_crossings(["J" | rest], "L", count), do: count_crossings(rest, nil, count)
  defp count_crossings(["J" | rest], "F", count), do: count_crossings(rest, nil, count + 1)
  defp count_crossings(["7" | rest], "L", count), do: count_crossings(rest, nil, count + 1)
  defp count_crossings(["7" | rest], "F", count), do: count_crossings(rest, nil, count)
end
