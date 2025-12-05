import AOC

aoc 2020, 9 do
  @moduledoc """
  https://adventofcode.com/2020/day/9

  Encoding Error - XMAS cipher validation (sliding window, two-sum).
  """

  @doc """
  Find first number not sum of two from previous preamble.
  Use preamble=25 for real input, pass custom for examples.
  """
  def p1(input, preamble \\ 25) do
    numbers = parse(input)
    find_invalid(numbers, preamble)
  end

  @doc """
  Find contiguous range summing to Part 1 answer, return min+max.
  """
  def p2(input, preamble \\ 25) do
    numbers = parse(input)
    target = find_invalid(numbers, preamble)
    range = find_contiguous_sum(numbers, target)
    Enum.min(range) + Enum.max(range)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_invalid(numbers, preamble) do
    numbers
    |> Enum.chunk_every(preamble + 1, 1, :discard)
    |> Enum.find_value(fn chunk ->
      {window, [target]} = Enum.split(chunk, preamble)
      unless valid_sum?(window, target), do: target
    end)
  end

  defp valid_sum?(window, target) do
    set = MapSet.new(window)
    Enum.any?(window, fn x ->
      complement = target - x
      complement != x and MapSet.member?(set, complement)
    end)
  end

  defp find_contiguous_sum(numbers, target) do
    find_contiguous_sum(numbers, target, 0, 0, 0)
  end

  defp find_contiguous_sum(numbers, target, left, right, sum) do
    cond do
      sum == target and right - left >= 2 ->
        Enum.slice(numbers, left, right - left)
      sum < target and right < length(numbers) ->
        find_contiguous_sum(numbers, target, left, right + 1, sum + Enum.at(numbers, right))
      sum >= target ->
        find_contiguous_sum(numbers, target, left + 1, right, sum - Enum.at(numbers, left))
      true ->
        nil
    end
  end
end
