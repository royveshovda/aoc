import AOC

aoc 2022, 13 do
  @moduledoc """
  Day 13: Distress Signal

  Compare pairs of nested lists.
  Part 1: Sum indices of pairs in correct order.
  Part 2: Find decoder key (product of divider packet indices after sort).
  """

  @doc """
  Part 1: Sum of indices of correctly ordered pairs.

  ## Examples

      iex> example = "[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]"
      iex> p1(example)
      13
  """
  def p1(input) do
    input
    |> parse_pairs()
    |> Enum.with_index(1)
    |> Enum.filter(fn {{left, right}, _idx} -> compare(left, right) == :lt end)
    |> Enum.map(fn {_pair, idx} -> idx end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Decoder key (product of [[2]] and [[6]] positions).

  ## Examples

      iex> example = "[1,1,3,1,1]\\n[1,1,5,1,1]\\n\\n[[1],[2,3,4]]\\n[[1],4]\\n\\n[9]\\n[[8,7,6]]\\n\\n[[4,4],4,4]\\n[[4,4],4,4,4]\\n\\n[7,7,7,7]\\n[7,7,7]\\n\\n[]\\n[3]\\n\\n[[[]]]\\n[[]]\\n\\n[1,[2,[3,[4,[5,6,7]]]],8,9]\\n[1,[2,[3,[4,[5,6,0]]]],8,9]"
      iex> p2(example)
      140
  """
  def p2(input) do
    divider1 = [[2]]
    divider2 = [[6]]

    packets =
      input
      |> parse_all()
      |> Kernel.++([divider1, divider2])
      |> Enum.sort(&(compare(&1, &2) == :lt))

    idx1 = Enum.find_index(packets, &(&1 == divider1)) + 1
    idx2 = Enum.find_index(packets, &(&1 == divider2)) + 1

    idx1 * idx2
  end

  defp parse_pairs(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pair ->
      [left, right] = String.split(pair, "\n", trim: true)
      {parse_packet(left), parse_packet(right)}
    end)
  end

  defp parse_all(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
  end

  defp parse_packet(str) do
    {result, _} = Code.eval_string(str)
    result
  end

  # Compare two values
  defp compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left > right -> :gt
      true -> :eq
    end
  end

  defp compare(left, right) when is_list(left) and is_list(right) do
    compare_lists(left, right)
  end

  defp compare(left, right) when is_integer(left) and is_list(right) do
    compare([left], right)
  end

  defp compare(left, right) when is_list(left) and is_integer(right) do
    compare(left, [right])
  end

  defp compare_lists([], []), do: :eq
  defp compare_lists([], _), do: :lt
  defp compare_lists(_, []), do: :gt

  defp compare_lists([lh | lt], [rh | rt]) do
    case compare(lh, rh) do
      :eq -> compare_lists(lt, rt)
      result -> result
    end
  end
end
