import AOC

aoc 2016, 9 do
  @moduledoc """
  https://adventofcode.com/2016/day/9
  Day 9: Explosives in Cyberspace - string decompression
  """

  def p1(input) do
    input
    |> String.trim()
    |> String.replace(~r/\s/, "")
    |> decompress_length(false)
  end

  def p2(input) do
    input
    |> String.trim()
    |> String.replace(~r/\s/, "")
    |> decompress_length(true)
  end

  defp decompress_length("", _recursive), do: 0

  defp decompress_length("(" <> rest, recursive) do
    [marker, remainder] = String.split(rest, ")", parts: 2)
    [len, times] = marker |> String.split("x") |> Enum.map(&String.to_integer/1)

    {data, after_data} = String.split_at(remainder, len)

    data_length = if recursive, do: decompress_length(data, true), else: String.length(data)

    data_length * times + decompress_length(after_data, recursive)
  end

  defp decompress_length(<<_char, rest::binary>>, recursive) do
    1 + decompress_length(rest, recursive)
  end
end
