import AOC

aoc 2024, 15 do
  @moduledoc """
  https://adventofcode.com/2024/day/15
  Source: https://github.com/liamcmitchell/advent-of-code/blob/main/2024/15/1.exs
  """

  def p1(input) do
    {map, directions} = parse(input)

    map
    |> execute(directions)
    |> Enum.filter(&match?({_, :box}, &1))
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end

  def p2(input) do
    {map, directions} = parse(input)

    map
    |> widen()
    |> execute(directions)
    |> Enum.filter(&match?({_, :boxl}, &1))
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end

  def parse(input) do
    [map, directions] = String.split(input, "\n\n")

    map =
      for {row, y} <- Enum.with_index(String.split(map, "\n")),
          {char, x} <- Enum.with_index(String.to_charlist(row)),
          char !== ?.,
          into: %{} do
        val =
          case char do
            ?# -> :wall
            ?O -> :box
            ?@ -> :robot
          end

        {{x, y}, val}
      end

    directions =
      for <<char <- directions>>, char !== ?\n do
        case char do
          ?< -> {-1, 0}
          ?^ -> {0, -1}
          ?> -> {1, 0}
          ?v -> {0, 1}
        end
      end

    {map, directions}
  end

  def execute(map, directions) do
    {pos, _} = Enum.find(map, &match?({_, :robot}, &1))

    directions
    |> Enum.reduce({pos, map}, fn direction, {pos, map} ->
      case movable(map, pos, direction) do
        nil ->
          {pos, map}

        positions ->
          {add(pos, direction), move(map, positions, direction)}
      end
    end)
    |> elem(1)
  end

  def widen(map) do
    map
    |> Enum.flat_map(fn {{x, y}, object} ->
      case object do
        :robot ->
          [{{x * 2, y}, :robot}]

        :box ->
          [
            {{x * 2, y}, :boxl},
            {{x * 2 + 1, y}, :boxr}
          ]

        :wall ->
          [
            {{x * 2, y}, :wall},
            {{x * 2 + 1, y}, :wall}
          ]
      end
    end)
    |> Map.new()
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def move(map, positions, direction) do
    moved =
      positions
      |> Enum.map(fn pos -> {add(pos, direction), Map.get(map, pos)} end)
      |> Map.new()

    map |> Map.drop(positions) |> Map.merge(moved)
  end

  def movable(map, pos, direction) do
    case Map.get(map, pos) do
      :wall ->
        nil

      nil ->
        []

      box1
      when (box1 == :boxl or box1 == :boxr) and (direction == {0, 1} or direction == {0, -1}) ->
        pos2 = if box1 == :boxr, do: add(pos, {-1, 0}), else: add(pos, {1, 0})

        case {movable(map, add(pos, direction), direction),
              movable(map, add(pos2, direction), direction)} do
          {nil, _} -> nil
          {_, nil} -> nil
          {p1, p2} -> [pos, pos2 | p1] ++ p2
        end

      _ ->
        case movable(map, add(pos, direction), direction) do
          nil -> nil
          positions -> [pos | positions]
        end
    end
  end
end
