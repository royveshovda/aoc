import AOC

aoc 2016, 16 do
  @moduledoc """
  https://adventofcode.com/2016/day/16
  """

  def p1(input) do
    initial = String.trim(input)
    solve(initial, 272)
  end

  def p2(input) do
    initial = String.trim(input)
    solve(initial, 35651584)
  end

  defp solve(initial, length) do
    initial
    |> generate_data(length)
    |> String.slice(0, length)
    |> checksum()
  end

  defp generate_data(a, target_length) do
    if String.length(a) >= target_length do
      a
    else
      b = a |> String.reverse() |> String.graphemes() |> Enum.map(&flip/1) |> Enum.join()
      generate_data(a <> "0" <> b, target_length)
    end
  end

  defp flip("0"), do: "1"
  defp flip("1"), do: "0"

  defp checksum(data) do
    result =
      data
      |> String.graphemes()
      |> Enum.chunk_every(2)
      |> Enum.map(fn
        [a, a] -> "1"
        _ -> "0"
      end)
      |> Enum.join()

    if rem(String.length(result), 2) == 0 do
      checksum(result)
    else
      result
    end
  end
end
