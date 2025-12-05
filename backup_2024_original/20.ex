import AOC

aoc 2024, 20 do
  @moduledoc """
  https://adventofcode.com/2024/day/20
  Source: https://github.com/liamcmitchell/advent-of-code/blob/main/2024/20/1.exs
  """

  def p1(input) do
    input
    |> parse()
    |> shortest()
    |> cheats(2, 100)
    |> Enum.count()

  end

  def p2(input) do
    input
    |> parse()
    |> shortest()
    |> cheats(20, 100)
    |> Enum.count()
  end

  def parse(input) do
    for {row, y} <- Enum.with_index(String.split(input, "\n")),
        {char, x} <- Enum.with_index(String.to_charlist(row)),
        char !== ?.,
        into: %{} do
      val =
        case char do
          ?# -> :wall
          ?S -> :start
          ?E -> :end
        end

      {{x, y}, val}
    end
  end

  def visit(map, unvisited, seen, goal) do
    if :queue.is_empty(unvisited) do
      nil
    else
      path = :queue.get(unvisited)
      {pos, time} = hd(path)

      next =
        directions()
        |> Enum.map(&add(&1, pos))
        |> Enum.reject(fn pos ->
          MapSet.member?(seen, pos) or Map.get(map, pos) == :wall
        end)

      if Enum.member?(next, goal) do
        [{goal, time + 1} | path]
      else
        unvisited =
          next
          |> Enum.reduce(unvisited, fn next, unvisited ->
            :queue.in([{next, time + 1} | path], unvisited)
          end)
          |> :queue.drop()

        seen = seen |> MapSet.union(MapSet.new(next))

        visit(map, unvisited, seen, goal)
      end
    end
  end

  def shortest(map) do
    {start, _} = Enum.find(map, &match?({_, :start}, &1))
    {goal, _} = Enum.find(map, &match?({_, :end}, &1))
    unvisited = :queue.from_list([[{start, 0}]])
    seen = MapSet.new([start])
    visit(map, unvisited, seen, goal)
  end

  def directions() do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  end

  def add({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def search_area(n) do
    for x <- -n..n,
        y <- -n..n,
        duration = abs(x) + abs(y),
        duration > 0 and duration <= n do
      {{x, y}, duration}
    end
  end

  def cheats(path, duration, min) do
    map = Map.new(path)
    area = search_area(duration)

    path
    |> Enum.flat_map(fn {pos, time} ->
      area
      |> Enum.flat_map(fn {offset, duration} ->
        target_time = Map.get(map, add(pos, offset))

        if is_integer(target_time) do
          saved = target_time - time - duration

          if saved >= min do
            [saved]
          end
        end || []
      end)
    end)
  end
end
