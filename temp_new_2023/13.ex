import AOC

aoc 2023, 13 do
  @moduledoc """
  https://adventofcode.com/2023/day/13

  Mirror reflections. Optimized with byte-level comparison.
  """

  @doc """
      iex> p1(example_string())
      405

      iex> p1(input_string())
      37975
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&find_reflection(&1, 0))
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      400

      iex> p2(input_string())
      32497
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&find_reflection(&1, 1))
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern ->
      String.split(pattern, "\n", trim: true)
    end)
  end

  defp find_reflection(pattern, smudges) do
    # Try horizontal reflection (rows)
    case find_mirror(pattern, smudges) do
      nil ->
        # Try vertical reflection (columns)
        transposed = transpose(pattern)
        find_mirror(transposed, smudges)
      row ->
        row * 100
    end
  end

  defp find_mirror(rows, expected_diff) do
    len = length(rows)

    1..(len - 1)
    |> Enum.find(fn i ->
      above = Enum.take(rows, i) |> Enum.reverse()
      below = Enum.drop(rows, i)

      # Early termination with reduce_while
      diff_count =
        Enum.zip(above, below)
        |> Enum.reduce_while(0, fn {a, b}, acc ->
          diff = count_differences(a, b)
          new_acc = acc + diff
          if new_acc > expected_diff, do: {:halt, new_acc}, else: {:cont, new_acc}
        end)

      diff_count == expected_diff
    end)
  end

  # Use :binary.bin_to_list for fast byte comparison
  defp count_differences(str1, str2) do
    bytes1 = :binary.bin_to_list(str1)
    bytes2 = :binary.bin_to_list(str2)
    count_diff(bytes1, bytes2, 0)
  end

  defp count_diff([], [], acc), do: acc
  defp count_diff([h | t1], [h | t2], acc), do: count_diff(t1, t2, acc)
  defp count_diff([_ | t1], [_ | t2], acc), do: count_diff(t1, t2, acc + 1)

  defp transpose(rows) do
    rows
    |> Enum.map(&:binary.bin_to_list/1)
    |> Enum.zip()
    |> Enum.map(fn tuple -> tuple |> Tuple.to_list() |> :binary.list_to_bin() end)
  end
end
