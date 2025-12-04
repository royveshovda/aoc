import AOC

aoc 2025, 2 do
  @moduledoc """
  https://adventofcode.com/2025/day/2
  """

  @doc """
      iex> p1(example_string(0))
      1227775554
  """
  def p1(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")
    |> String.split(",")
    |> Enum.flat_map(&parse_range/1)
    |> Enum.filter(&is_invalid_id?/1)
    |> Enum.sum()
  end

  defp parse_range(range) do
    [first, last] = String.split(range, "-") |> Enum.map(&String.to_integer/1)
    first..last
  end

  defp is_invalid_id?(id) do
    id_str = Integer.to_string(id)
    len = String.length(id_str)

    # Must have even length to be repeatable
    if rem(len, 2) == 0 do
      half = div(len, 2)
      first_half = String.slice(id_str, 0, half)
      second_half = String.slice(id_str, half, half)

      # Check if both halves are identical and no leading zeros
      first_half == second_half and not String.starts_with?(first_half, "0")
    else
      false
    end
  end

  @doc """
      iex> p2(example_string(0))
      4174379265
  """
  def p2(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")
    |> String.split(",")
    |> Enum.flat_map(&parse_range/1)
    |> Enum.filter(&is_invalid_id_v2?/1)
    |> Enum.sum()
  end

  defp is_invalid_id_v2?(id) do
    id_str = Integer.to_string(id)
    len = String.length(id_str)

    # Try all possible pattern lengths from 1 to len/2
    # Check if the string is that pattern repeated at least twice
    1..div(len, 2)//1
    |> Enum.any?(fn pattern_len ->
      # Only consider if pattern divides length evenly
      if rem(len, pattern_len) == 0 do
        pattern = String.slice(id_str, 0, pattern_len)
        # Check if entire string is this pattern repeated
        # and no leading zeros
        repetitions = div(len, pattern_len)
        String.duplicate(pattern, repetitions) == id_str and
          not String.starts_with?(pattern, "0")
      else
        false
      end
    end)
  end
end
