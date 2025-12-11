import AOC

aoc 2016, 4 do
  @moduledoc """
  https://adventofcode.com/2016/day/4
  Day 4: Security Through Obscurity
  Validate room names and find sector IDs.
  """

  def p1(input) do
    input
    |> parse_rooms()
    |> Enum.filter(&valid_room?/1)
    |> Enum.map(fn {_, sector, _} -> sector end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse_rooms()
    |> Enum.filter(&valid_room?/1)
    |> Enum.find(fn {name, sector, _} ->
      decrypt_name(name, sector) =~ "north"
    end)
    |> elem(1)
  end

  defp parse_rooms(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_room/1)
  end

  defp parse_room(line) do
    ~r/^([a-z-]+)-(\d+)\[([a-z]+)\]$/
    |> Regex.run(line)
    |> case do
      [_, name, sector, checksum] ->
        {name, String.to_integer(sector), checksum}
    end
  end

  defp valid_room?({name, _sector, checksum}) do
    computed_checksum =
      name
      |> String.replace("-", "")
      |> String.graphemes()
      |> Enum.frequencies()
      |> Enum.sort_by(fn {char, count} -> {-count, char} end)
      |> Enum.take(5)
      |> Enum.map(fn {char, _} -> char end)
      |> Enum.join()

    computed_checksum == checksum
  end

  defp decrypt_name(name, sector) do
    name
    |> String.graphemes()
    |> Enum.map(fn
      "-" -> " "
      char -> rotate_char(char, sector)
    end)
    |> Enum.join()
  end

  defp rotate_char(char, n) do
    <<c>> = char
    offset = rem(c - ?a + n, 26)
    <<(?a + offset)>>
  end
end
