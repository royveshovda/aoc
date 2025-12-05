import AOC

aoc 2020, 25 do
  @moduledoc """
  https://adventofcode.com/2020/day/25

  Combo Breaker - RFID encryption (discrete logarithm).
  """

  @modulo 20201227
  @subject 7

  @doc """
  Find encryption key by discovering loop sizes.

  ## Examples

      iex> p1("5764801\\n17807724")
      14897079
  """
  def p1(input) do
    [card_pub, door_pub] = parse(input)
    card_loop = find_loop_size(card_pub)
    transform(door_pub, card_loop)
  end

  def p2(_input) do
    "⭐ Merry Christmas! ⭐"
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_loop_size(target) do
    find_loop_size(1, 0, target)
  end

  defp find_loop_size(value, loop, target) do
    if value == target do
      loop
    else
      find_loop_size(rem(value * @subject, @modulo), loop + 1, target)
    end
  end

  defp transform(subject, loop_size) do
    transform(1, subject, loop_size)
  end

  defp transform(value, _subject, 0), do: value
  defp transform(value, subject, loops) do
    transform(rem(value * subject, @modulo), subject, loops - 1)
  end
end
