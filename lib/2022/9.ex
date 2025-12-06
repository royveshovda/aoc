import AOC

aoc 2022, 9 do
  @moduledoc """
  Day 9: Rope Bridge

  Simulate rope with head and tail.
  Part 1: 2 knots (head + 1 tail).
  Part 2: 10 knots (head + 9 tails).
  Count unique positions visited by last knot.
  """

  @doc """
  Part 1: Count unique positions visited by tail (2 knots).

  ## Examples

      iex> example = "R 4\\nU 4\\nL 3\\nD 1\\nR 4\\nD 1\\nL 5\\nR 2"
      iex> p1(example)
      13
  """
  def p1(input) do
    simulate(input, 2)
  end

  @doc """
  Part 2: Count unique positions visited by 9th tail (10 knots).

  ## Examples

      iex> example = "R 4\\nU 4\\nL 3\\nD 1\\nR 4\\nD 1\\nL 5\\nR 2"
      iex> p2(example)
      1

      iex> example2 = "R 5\\nU 8\\nL 8\\nD 3\\nR 17\\nD 10\\nL 25\\nU 20"
      iex> p2(example2)
      36
  """
  def p2(input) do
    simulate(input, 10)
  end

  defp simulate(input, num_knots) do
    moves = parse(input)
    initial_rope = List.duplicate({0, 0}, num_knots)

    {_rope, visited} =
      Enum.reduce(moves, {initial_rope, MapSet.new([{0, 0}])}, fn {dir, count}, {rope, visited} ->
        Enum.reduce(1..count, {rope, visited}, fn _, {rope, visited} ->
          rope = move_rope(rope, dir)
          visited = MapSet.put(visited, List.last(rope))
          {rope, visited}
        end)
      end)

    MapSet.size(visited)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, count] = String.split(line, " ")
      {dir, String.to_integer(count)}
    end)
  end

  defp move_rope([head | tail], dir) do
    new_head = move_head(head, dir)

    {new_tail, _} =
      Enum.map_reduce(tail, new_head, fn knot, prev ->
        new_knot = follow(knot, prev)
        {new_knot, new_knot}
      end)

    [new_head | new_tail]
  end

  defp move_head({x, y}, "R"), do: {x + 1, y}
  defp move_head({x, y}, "L"), do: {x - 1, y}
  defp move_head({x, y}, "U"), do: {x, y + 1}
  defp move_head({x, y}, "D"), do: {x, y - 1}

  defp follow({tx, ty}, {hx, hy}) do
    dx = hx - tx
    dy = hy - ty

    # If touching (adjacent or overlapping), don't move
    if abs(dx) <= 1 and abs(dy) <= 1 do
      {tx, ty}
    else
      # Move one step toward head in each dimension
      {tx + sign(dx), ty + sign(dy)}
    end
  end

  defp sign(0), do: 0
  defp sign(n) when n > 0, do: 1
  defp sign(n) when n < 0, do: -1
end
