import AOC

aoc 2023, 12 do
  @moduledoc """
  https://adventofcode.com/2023/day/12
  """

  @doc """
      iex> p1(example_string())
      21

      iex> p1(input_string())
      8180
  """
  def p1(input) do
    # parse input
    # count ? . and #
    # try all combinations of ? -> verify if it matches

    input
    |> parse()
    |> Enum.map(&calculate_options_for_line/1)
    |> Enum.sum()
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [positions, pattern] = String.split(line, " ")
    positions = String.graphemes(positions)
    pattern = String.split(pattern, ",") |> Enum.map(&String.to_integer/1)
    {positions, pattern}
  end

  def calculate_options_for_line({positions, pattern}) do
    options = expand_options(positions)
    Enum.filter(options, fn o -> correct_pattern?(o, pattern) end) |> Enum.count()
    #{positions, pattern}
  end

  def correct_pattern?(arrangment, pattern) do
    arrangment_pattern = create_pattern(arrangment, 0, [])
    arrangment_pattern == pattern
  end

  def create_pattern([], current_count, acc) do
    [current_count | acc] |> Enum.reverse() |> Enum.filter(&(&1 != 0))
  end

  def create_pattern(["#" | rest], current_count, acc) do
    create_pattern(rest, current_count + 1, acc)
  end

  def create_pattern(["." | rest], current_count, acc) do
    create_pattern(rest, 0, [current_count | acc])
  end

  def expand_options(arrantment) do
    count = Enum.filter(arrantment, &(&1 == "?")) |> Enum.count()
    # create all permutations of # and . with length count
    combinations(count)
    |> Enum.map(fn c -> merge_options(arrantment, c, []) end)
  end


  def merge_options([], [], acc) do
    acc |> Enum.reverse()
  end

  def merge_options(["?" | rest], [x | combi], acc) do
    merge_options(rest, combi, [x | acc])
  end

  def merge_options(["." | rest], combi, acc) do
    merge_options(rest, combi, ["." | acc])
  end

  def merge_options(["#" | rest], combi, acc) do
    merge_options(rest, combi, ["#" | acc])
  end

  # def merge_options(arrantment, combi) do
  #   Enum.reduce(arrantment, {combi, []}, fn x, {combi, acc} ->
  #     case x do
  #       "?" -> {Enum.drop(combi, 1), [Enum.at(combi, 0) | acc]}
  #       _ -> {combi, [x | acc]}
  #     end
  #   end)
  # end

  def combinations(1) do
    [["#"], ["."]]
  end

  def combinations(n) do
    reduced = combinations(n - 1)
    left = Enum.map(reduced, fn x -> ["#" | x] end)
    right = Enum.map(reduced, fn x -> ["." | x] end)
    left ++ right
  end

  @doc """
      iex> p2(example_string())
      525152

      iex> p2(input_string())
      620189727003627
  """
  def p2(input) do
    for {s, ns} <- parse_p2(input) do
      solve("#{s}?#{s}?#{s}?#{s}?#{s}", nil, List.flatten([ns, ns, ns, ns, ns]))
    end
    |> Enum.sum()
  end

  defp parse_p2(input) do
    for line <- String.split(input, "\n", trim: true) do
      [pattern, ns] = String.split(line)
      {pattern, String.split(ns, ",") |> Enum.map(&String.to_integer/1)}
    end
  end

  defp solve(a, b, c) do
    if cached = Process.get({a, b, c}) do
      cached
    else
      r = solver(a, b, c)
      Process.put({a, b, c}, r)
      r
    end
  end

  defp solver("", n, [n]), do: 1
  defp solver("", nil, []), do: 1
  defp solver("", _, _), do: 0
  defp solver("." <> s, nil, cons), do: solve(s, nil, cons)
  defp solver("?" <> s, nil, []), do: solve(s, nil, [])
  defp solver("?" <> s, nil, cons), do: solve(s, 1, cons) + solve(s, nil, cons)
  defp solver("#" <> s, nil, cons = [_ | _]), do: solve(s, 1, cons)
  defp solver("." <> s, n, [n | ns]), do: solve(s, nil, ns)
  defp solver("?" <> s, n, [n | ns]), do: solve(s, nil, ns)
  defp solver("#" <> s, n, cons = [e | _]) when n < e, do: solve(s, n + 1, cons)
  defp solver("?" <> s, n, cons = [e | _]) when n < e, do: solve(s, n + 1, cons)
  defp solver(_, _, _), do: 0

  def expand_for_p2(lines) do
    Enum.map(lines, fn {positions, pattern} ->
      pos = List.to_string(positions)
      expanded_positions =
        [pos, pos, pos, pos, pos]
        |> Enum.join("?")
        |> String.graphemes()

      pat = Enum.join(pattern, ",")
      expanded_patterns =
        [pat, pat, pat, pat, pat]
        |> Enum.join(",")
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      {expanded_positions, expanded_patterns}
    end)
  end
end
