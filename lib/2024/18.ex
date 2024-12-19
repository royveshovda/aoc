import AOC

aoc 2024, 18 do
  @moduledoc """
  https://adventofcode.com/2024/day/18
  """

  def p1({input, read_length, size}) do
    # def part1(input, max \\ 70, n \\ 1024) do
    grid = parse(input)
    |> Enum.take(read_length)
    |> MapSet.new
    grid = {grid, 0..size}
    start = {0, 0}
    goal = {size, size}
    q = q_new({0, start})
    seen = MapSet.new([start])
    walk(q, goal, grid, seen)
  end


  def p2({input, read_length, size}) do
    {first, rest} = Enum.split(parse(input), read_length)
    grid = {MapSet.new(first), 0..size}
    start = {0, 0}
    goal = {size, size}
    q = q_new({0, start})
    seen = MapSet.new([start])

    pos =
      Enum.reduce_while(rest, grid, fn next, {grid, r} ->
        grid = {MapSet.put(grid, next), r}
        case walk(q, goal, grid, seen) do
          nil ->
            {:halt, next}
          _steps ->
            {:cont, grid}
        end
      end)

    {x, y} = pos
    "#{x},#{y}"
  end

  defp walk(q, goal, grid, seen) do
    case q_take_smallest(q) do
      nil ->
        nil
      {{steps, current}, q} ->
        new = adjacent_squares(current)
        |> Enum.reject(fn next ->
          blocked?(next, grid) or MapSet.member?(seen, next)
        end)
        if Enum.member?(new, goal) do
          steps + 1
        else
          seen = MapSet.union(seen, MapSet.new(new))
          q = Enum.reduce(new, q, fn next, q ->
            q_put(q, {steps + 1, next})
          end)
          walk(q, goal, grid, seen)
        end
    end
  end

  defp q_new(e) do
    :queue.from_list([e])
  end

  defp q_put(q, e) do
    :queue.in(e, q)
  end

  defp q_take_smallest(q) do
    case :queue.is_empty(q) do
      true ->
        nil
      false ->
        {:queue.get(q), :queue.drop(q)}
    end
  end

  defp blocked?({row, col}, {grid, r}) do
    (row not in r) or (col not in r) or
    MapSet.member?(grid, {row, col})
  end

  defp adjacent_squares({row, col}) do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end
end
