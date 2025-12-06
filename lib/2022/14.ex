import AOC

aoc 2022, 14 do
  @moduledoc """
  Day 14: Regolith Reservoir

  Simulate sand falling from (500, 0).
  Part 1: Count sand until it falls into abyss.
  Part 2: Count sand until source is blocked (with infinite floor).
  """

  @doc """
  Part 1: Units of sand before falling into void.

  ## Examples

      iex> example = "498,4 -> 498,6 -> 496,6\\n503,4 -> 502,4 -> 502,9 -> 494,9"
      iex> p1(example)
      24
  """
  def p1(input) do
    rocks = parse(input)
    max_y = rocks |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    drop_sand(rocks, max_y, false, 0)
  end

  @doc """
  Part 2: Units of sand until source blocked (floor at max_y + 2).

  ## Examples

      iex> example = "498,4 -> 498,6 -> 496,6\\n503,4 -> 502,4 -> 502,9 -> 494,9"
      iex> p2(example)
      93
  """
  def p2(input) do
    rocks = parse(input)
    max_y = rocks |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    floor_y = max_y + 2
    drop_sand(rocks, floor_y, true, 0)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&parse_path/1)
    |> MapSet.new()
  end

  defp parse_path(line) do
    points =
      line
      |> String.split(" -> ")
      |> Enum.map(fn coord ->
        [x, y] = String.split(coord, ",")
        {String.to_integer(x), String.to_integer(y)}
      end)

    points
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn [{x1, y1}, {x2, y2}] ->
      for x <- x1..x2, y <- y1..y2, do: {x, y}
    end)
  end

  defp drop_sand(occupied, limit, has_floor, count) do
    case fall_sand({500, 0}, occupied, limit, has_floor) do
      :abyss -> count
      :blocked -> count
      pos ->
        if pos == {500, 0} do
          count + 1
        else
          drop_sand(MapSet.put(occupied, pos), limit, has_floor, count + 1)
        end
    end
  end

  defp fall_sand({x, y}, occupied, limit, has_floor) do
    cond do
      # Check if we're at the source and it's blocked
      {x, y} == {500, 0} and MapSet.member?(occupied, {500, 0}) ->
        :blocked

      # For part 1: falling into abyss
      not has_floor and y >= limit ->
        :abyss

      # For part 2: hit the floor
      has_floor and y + 1 == limit ->
        {x, y}

      # Try to fall down
      not MapSet.member?(occupied, {x, y + 1}) ->
        fall_sand({x, y + 1}, occupied, limit, has_floor)

      # Try down-left
      not MapSet.member?(occupied, {x - 1, y + 1}) ->
        fall_sand({x - 1, y + 1}, occupied, limit, has_floor)

      # Try down-right
      not MapSet.member?(occupied, {x + 1, y + 1}) ->
        fall_sand({x + 1, y + 1}, occupied, limit, has_floor)

      # Sand comes to rest
      true ->
        {x, y}
    end
  end
end
