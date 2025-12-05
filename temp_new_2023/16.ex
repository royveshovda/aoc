import AOC

aoc 2023, 16 do
  @moduledoc """
  https://adventofcode.com/2023/day/16

  Light beam traveling through a contraption with mirrors and splitters.
  """

  @doc """
      iex> p1(example_string())
      46

      iex> p1(input_string())
      7608
  """
  def p1(input) do
    grid = parse(input)
    count_energized(grid, {0, 0, :right})
  end

  @doc """
      iex> p2(example_string())
      51

      iex> p2(input_string())
      8221
  """
  def p2(input) do
    grid = parse(input)
    {max_row, max_col} = grid |> Map.keys() |> Enum.reduce({0, 0}, fn {r, c}, {mr, mc} ->
      {max(r, mr), max(c, mc)}
    end)

    # All possible entry points
    top = for c <- 0..max_col, do: {0, c, :down}
    bottom = for c <- 0..max_col, do: {max_row, c, :up}
    left = for r <- 0..max_row, do: {r, 0, :right}
    right = for r <- 0..max_row, do: {r, max_col, :left}

    (top ++ bottom ++ left ++ right)
    |> Enum.map(&count_energized(grid, &1))
    |> Enum.max()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, c} -> {{r, c}, char} end)
    end)
    |> Map.new()
  end

  defp count_energized(grid, start) do
    trace_beam(grid, [start], MapSet.new())
    |> Enum.map(fn {r, c, _dir} -> {r, c} end)
    |> Enum.uniq()
    |> length()
  end

  defp trace_beam(_grid, [], visited), do: visited
  defp trace_beam(grid, [{r, c, dir} = beam | rest], visited) do
    if MapSet.member?(visited, beam) or not Map.has_key?(grid, {r, c}) do
      trace_beam(grid, rest, visited)
    else
      visited = MapSet.put(visited, beam)
      cell = Map.get(grid, {r, c})
      next_beams = next_positions(r, c, dir, cell)
      trace_beam(grid, next_beams ++ rest, visited)
    end
  end

  defp next_positions(r, c, dir, cell) do
    case {cell, dir} do
      # Empty space or aligned splitter - continue straight
      {".", :right} -> [{r, c + 1, :right}]
      {".", :left} -> [{r, c - 1, :left}]
      {".", :up} -> [{r - 1, c, :up}]
      {".", :down} -> [{r + 1, c, :down}]

      {"-", :right} -> [{r, c + 1, :right}]
      {"-", :left} -> [{r, c - 1, :left}]
      {"-", :up} -> [{r, c - 1, :left}, {r, c + 1, :right}]
      {"-", :down} -> [{r, c - 1, :left}, {r, c + 1, :right}]

      {"|", :up} -> [{r - 1, c, :up}]
      {"|", :down} -> [{r + 1, c, :down}]
      {"|", :right} -> [{r - 1, c, :up}, {r + 1, c, :down}]
      {"|", :left} -> [{r - 1, c, :up}, {r + 1, c, :down}]

      # / mirror
      {"/", :right} -> [{r - 1, c, :up}]
      {"/", :left} -> [{r + 1, c, :down}]
      {"/", :up} -> [{r, c + 1, :right}]
      {"/", :down} -> [{r, c - 1, :left}]

      # \ mirror
      {"\\", :right} -> [{r + 1, c, :down}]
      {"\\", :left} -> [{r - 1, c, :up}]
      {"\\", :up} -> [{r, c - 1, :left}]
      {"\\", :down} -> [{r, c + 1, :right}]
    end
  end
end
