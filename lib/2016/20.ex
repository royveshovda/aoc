import AOC

aoc 2016, 20 do
  @moduledoc """
  https://adventofcode.com/2016/day/20
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    ranges = parse(input)
    merged = merge_ranges(ranges)

    # Find first gap
    case merged do
      [{_start, end_val} | _] when end_val < 4294967295 -> end_val + 1
      _ -> 0
    end
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    ranges = parse(input)
    merged = merge_ranges(ranges)
    count_allowed(merged, 4294967295)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [start, end_val] = String.split(line, "-")
      {String.to_integer(start), String.to_integer(end_val)}
    end)
    |> Enum.sort()
  end

  defp merge_ranges(ranges) do
    ranges
    |> Enum.reduce([], fn {start, end_val}, acc ->
      case acc do
        [] -> [{start, end_val}]
        [{prev_start, prev_end} | rest] ->
          if start <= prev_end + 1 do
            [{prev_start, max(prev_end, end_val)} | rest]
          else
            [{start, end_val}, {prev_start, prev_end} | rest]
          end
      end
    end)
    |> Enum.reverse()
  end

  defp count_allowed(merged, max_ip) do
    # Count blocked IPs
    blocked = merged |> Enum.map(fn {s, e} -> e - s + 1 end) |> Enum.sum()
    # Total IPs (0 to max_ip inclusive) minus blocked
    (max_ip + 1) - blocked
  end
end
