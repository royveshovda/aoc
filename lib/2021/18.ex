import AOC

aoc 2021, 18 do
  @moduledoc """
  Day 18: Snailfish

  Snailfish math with nested pairs.
  - Add: [[a,b], [c,d]]
  - Reduce: explode (depth >= 4) and split (>= 10) until stable
  - Magnitude: 3*left + 2*right
  """

  @doc """
  Part 1: Sum all snailfish numbers and compute magnitude.

  ## Examples

      iex> p1("[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]\\n[[[5,[2,8]],4],[5,[[9,9],0]]]\\n[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]\\n[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]\\n[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]\\n[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]\\n[[[[5,4],[7,7]],8],[[8,3],8]]\\n[[9,3],[[9,9],[6,[4,9]]]]\\n[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]\\n[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]")
      4140
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.reduce(fn num, acc ->
      add(acc, num)
    end)
    |> magnitude()
  end

  @doc """
  Part 2: Find largest magnitude from adding any two different numbers.

  ## Examples

      iex> p2("[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]\\n[[[5,[2,8]],4],[5,[[9,9],0]]]\\n[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]\\n[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]\\n[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]\\n[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]\\n[[[[5,4],[7,7]],8],[[8,3],8]]\\n[[9,3],[[9,9],[6,[4,9]]]]\\n[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]\\n[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]")
      3993
  """
  def p2(input) do
    numbers = parse(input)

    for a <- numbers, b <- numbers, a != b do
      add(a, b) |> magnitude()
    end
    |> Enum.max()
  end

  defp add(a, b) do
    reduce([a, b])
  end

  defp reduce(num) do
    case explode(num) do
      {:exploded, new_num, _, _} ->
        reduce(new_num)

      :no_change ->
        case split(num) do
          {:split, new_num} -> reduce(new_num)
          :no_change -> num
        end
    end
  end

  # Explode: find leftmost pair at depth 4
  defp explode(num), do: explode(num, 0)

  defp explode(n, _depth) when is_integer(n), do: :no_change

  defp explode([left, right], 4) when is_integer(left) and is_integer(right) do
    {:exploded, 0, left, right}
  end

  defp explode([left, right], depth) do
    case explode(left, depth + 1) do
      {:exploded, new_left, add_left, add_right} ->
        {:exploded, [new_left, add_to_leftmost(right, add_right)], add_left, 0}

      :no_change ->
        case explode(right, depth + 1) do
          {:exploded, new_right, add_left, add_right} ->
            {:exploded, [add_to_rightmost(left, add_left), new_right], 0, add_right}

          :no_change ->
            :no_change
        end
    end
  end

  defp add_to_leftmost(n, 0), do: n
  defp add_to_leftmost(n, val) when is_integer(n), do: n + val
  defp add_to_leftmost([left, right], val), do: [add_to_leftmost(left, val), right]

  defp add_to_rightmost(n, 0), do: n
  defp add_to_rightmost(n, val) when is_integer(n), do: n + val
  defp add_to_rightmost([left, right], val), do: [left, add_to_rightmost(right, val)]

  # Split: find leftmost number >= 10
  defp split(n) when is_integer(n) and n >= 10 do
    {:split, [div(n, 2), div(n + 1, 2)]}
  end

  defp split(n) when is_integer(n), do: :no_change

  defp split([left, right]) do
    case split(left) do
      {:split, new_left} ->
        {:split, [new_left, right]}

      :no_change ->
        case split(right) do
          {:split, new_right} -> {:split, [left, new_right]}
          :no_change -> :no_change
        end
    end
  end

  defp magnitude(n) when is_integer(n), do: n
  defp magnitude([left, right]), do: 3 * magnitude(left) + 2 * magnitude(right)

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      {num, _} = Code.eval_string(line)
      num
    end)
  end
end
