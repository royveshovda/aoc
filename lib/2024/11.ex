import AOC

aoc 2024, 11 do
  @moduledoc """
  https://adventofcode.com/2024/day/11
  """

  def p1(input) do
    stones =
      input
      |> String.trim("\n") |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    stones
    |> Enum.flat_map(fn x -> handle_stone(x, 25) end)
    |> Enum.count()
  end

  @spec get_length_of_number(integer()) :: non_neg_integer()
  def get_length_of_number(number) do
    number
    |> Integer.to_string()
    |> String.length()
  end

  def handle_stone(stone, 0) do
    [stone]
  end

  def handle_stone(0, steps_left) do
    handle_stone(1, steps_left - 1)
  end

  def handle_stone(stone, steps_left) do
    case rem(get_length_of_number(stone), 2) == 0 do
      true ->
        split_stone_in_two(stone)
        |> Enum.flat_map(fn x -> handle_stone(x, steps_left - 1) end)
      false -> handle_stone(stone * 2024, steps_left - 1)
    end
  end

  def split_stone_in_two(stone) do
    {part1, part2} =
      stone
      |> Integer.to_string()
      |> String.split_at(round(get_length_of_number(stone) / 2))
    [String.to_integer(part1), String.to_integer(part2)]
  end


  def p2(input) do
    stones =
      input
      |> String.trim("\n") |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    stones
    |> Enum.flat_map(fn x -> handle_stone(x, 75) end)
    |> Enum.count()
  end
end
