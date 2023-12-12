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
      #iex> p2(example_string())
      #525152

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse()
    |> expand_for_p2()
    # Not working
    |> Enum.map(&calculate_options_for_line/1)
    |> Enum.sum()
  end

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
