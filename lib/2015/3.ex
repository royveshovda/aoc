import AOC

aoc 2015, 3 do
  @moduledoc """
  https://adventofcode.com/2015/day/3

  Day 3: Perfectly Spherical Houses in a Vacuum
  Track houses visited by Santa delivering presents on an infinite 2D grid.
  """

  @doc """
  Part 1: How many houses receive at least one present?

  Santa starts at origin and moves according to directions:
  - ^ = north (y+1)
  - v = south (y-1)
  - > = east (x+1)
  - < = west (x-1)

  Examples:
  - ">" delivers to 2 houses (start + 1 east)
  - "^>v<" delivers to 4 houses (square pattern)
  - "^v^v^v^v^v" delivers to 2 houses (back and forth)

      iex> p1(">")
      2

      iex> p1("^>v<")
      4

      iex> p1("^v^v^v^v^v")
      2
  """
  def p1(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce({{0, 0}, MapSet.new([{0, 0}])}, fn dir, {pos, visited} ->
      new_pos = move(pos, dir)
      {new_pos, MapSet.put(visited, new_pos)}
    end)
    |> elem(1)
    |> MapSet.size()
  end

  @doc """
  Part 2: Santa and Robo-Santa take turns following directions.
  How many houses receive at least one present?

  Santa takes even-indexed moves (0, 2, 4, ...)
  Robo-Santa takes odd-indexed moves (1, 3, 5, ...)

  Examples:
  - "^v" delivers to 3 houses (both start at origin, then move opposite directions)
  - "^>v<" delivers to 3 houses
  - "^v^v^v^v^v" delivers to 11 houses

      iex> p2("^v")
      3

      iex> p2("^>v<")
      3

      iex> p2("^v^v^v^v^v")
      11
  """
  def p2(input) do
    moves = input
    |> String.trim()
    |> String.graphemes()

    # Split moves between Santa and Robo-Santa
    santa_moves = moves |> Enum.take_every(2)
    robo_moves = moves |> Enum.drop(1) |> Enum.take_every(2)

    # Get houses visited by each
    santa_houses = get_visited_houses(santa_moves)
    robo_houses = get_visited_houses(robo_moves)

    # Union of both sets
    MapSet.union(santa_houses, robo_houses)
    |> MapSet.size()
  end

  defp get_visited_houses(moves) do
    moves
    |> Enum.reduce({{0, 0}, MapSet.new([{0, 0}])}, fn dir, {pos, visited} ->
      new_pos = move(pos, dir)
      {new_pos, MapSet.put(visited, new_pos)}
    end)
    |> elem(1)
  end

  defp move({x, y}, "^"), do: {x, y + 1}
  defp move({x, y}, "v"), do: {x, y - 1}
  defp move({x, y}, ">"), do: {x + 1, y}
  defp move({x, y}, "<"), do: {x - 1, y}
  defp move(pos, _), do: pos  # Ignore invalid directions
end
