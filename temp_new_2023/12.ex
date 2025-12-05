import AOC

aoc 2023, 12 do
  @moduledoc """
  https://adventofcode.com/2023/day/12

  Count valid spring arrangements. Uses memoization with Process dictionary.
  Optimized to use binary pattern matching instead of list operations.
  """

  @doc """
      iex> p1(example_string())
      21

      iex> p1(input_string())
      8180
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&count_arrangements/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      525152

      iex> p2(input_string())
      620189727003627
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&unfold/1)
    |> Enum.map(&count_arrangements/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [pattern, groups] = String.split(line, " ")
      groups = groups |> String.split(",") |> Enum.map(&String.to_integer/1)
      {pattern, groups}
    end)
  end

  defp unfold({pattern, groups}) do
    unfolded_pattern = "#{pattern}?#{pattern}?#{pattern}?#{pattern}?#{pattern}"
    unfolded_groups = List.flatten([groups, groups, groups, groups, groups])
    {unfolded_pattern, unfolded_groups}
  end

  defp count_arrangements({pattern, groups}) do
    result = solve(pattern, nil, groups)
    # Clean up process dictionary
    Process.get_keys()
    |> Enum.filter(&is_tuple/1)
    |> Enum.each(&Process.delete/1)
    result
  end

  # Memoized solver using Process dictionary (fast!)
  defp solve(pattern, current, groups) do
    key = {pattern, current, groups}
    case Process.get(key) do
      nil ->
        result = do_solve(pattern, current, groups)
        Process.put(key, result)
        result
      cached ->
        cached
    end
  end

  # Base cases
  defp do_solve("", n, [n]), do: 1
  defp do_solve("", nil, []), do: 1
  defp do_solve("", _, _), do: 0

  # Skip operational springs when not in a group
  defp do_solve("." <> rest, nil, groups), do: solve(rest, nil, groups)

  # ? when not in group and no groups left - treat as .
  defp do_solve("?" <> rest, nil, []), do: solve(rest, nil, [])

  # ? when not in group - try both . and #
  defp do_solve("?" <> rest, nil, groups) do
    solve(rest, 1, groups) + solve(rest, nil, groups)
  end

  # # starts a new group
  defp do_solve("#" <> rest, nil, [_ | _] = groups), do: solve(rest, 1, groups)

  # . ends current group if it matches expected size
  defp do_solve("." <> rest, n, [n | ns]), do: solve(rest, nil, ns)

  # ? can end current group if size matches
  defp do_solve("?" <> rest, n, [n | ns]), do: solve(rest, nil, ns)

  # # or ? continues current group if under expected size
  defp do_solve("#" <> rest, n, [e | _] = groups) when n < e, do: solve(rest, n + 1, groups)
  defp do_solve("?" <> rest, n, [e | _] = groups) when n < e, do: solve(rest, n + 1, groups)

  # No match - invalid
  defp do_solve(_, _, _), do: 0
end
