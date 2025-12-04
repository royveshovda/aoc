import AOC

aoc 2017, 9 do
  @moduledoc """
  https://adventofcode.com/2017/day/9
  """

  def p1(input) do
    {score, _} = process(input |> String.trim() |> String.graphemes(), 0, 0, false)
    score
  end

  def p2(input) do
    {_, garbage_count} = process(input |> String.trim() |> String.graphemes(), 0, 0, false)
    garbage_count
  end

  defp process([], score, garbage_count, _in_garbage), do: {score, garbage_count}

  defp process(["!" | rest], score, garbage_count, in_garbage) do
    # Skip next character
    [_ | rest2] = rest
    process(rest2, score, garbage_count, in_garbage)
  end

  defp process(["<" | rest], score, garbage_count, false) do
    # Start garbage
    process(rest, score, garbage_count, true)
  end

  defp process([">" | rest], score, garbage_count, true) do
    # End garbage
    process(rest, score, garbage_count, false)
  end

  defp process([_ | rest], score, garbage_count, true) do
    # Inside garbage, count it
    process(rest, score, garbage_count + 1, true)
  end

  defp process(["{" | rest], score, garbage_count, false) do
    # Start group
    {new_score, new_garbage, rest2} = process_group(rest, score, garbage_count, 1)
    process(rest2, new_score, new_garbage, false)
  end

  defp process([_ | rest], score, garbage_count, false) do
    # Skip other characters outside groups
    process(rest, score, garbage_count, false)
  end

  defp process_group(chars, score, garbage_count, depth) do
    process_group_inner(chars, score + depth, garbage_count, depth)
  end

  defp process_group_inner([], score, garbage_count, _depth), do: {score, garbage_count, []}

  defp process_group_inner(["!" | rest], score, garbage_count, depth) do
    [_ | rest2] = rest
    process_group_inner(rest2, score, garbage_count, depth)
  end

  defp process_group_inner(["<" | rest], score, garbage_count, depth) do
    {new_garbage, rest2} = consume_garbage(rest, garbage_count)
    process_group_inner(rest2, score, new_garbage, depth)
  end

  defp process_group_inner(["{" | rest], score, garbage_count, depth) do
    {new_score, new_garbage, rest2} = process_group(rest, score, garbage_count, depth + 1)
    process_group_inner(rest2, new_score, new_garbage, depth)
  end

  defp process_group_inner(["}" | rest], score, garbage_count, _depth) do
    {score, garbage_count, rest}
  end

  defp process_group_inner([_ | rest], score, garbage_count, depth) do
    process_group_inner(rest, score, garbage_count, depth)
  end

  defp consume_garbage([], count), do: {count, []}

  defp consume_garbage(["!" | rest], count) do
    [_ | rest2] = rest
    consume_garbage(rest2, count)
  end

  defp consume_garbage([">" | rest], count) do
    {count, rest}
  end

  defp consume_garbage([_ | rest], count) do
    consume_garbage(rest, count + 1)
  end
end
