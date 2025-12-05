import AOC

aoc 2024, 19 do
  @moduledoc """
  https://adventofcode.com/2024/day/19

  Linen Layout - Count possible/ways to make designs from towel patterns.
  """

  def p1(input) do
    {patterns, designs} = parse(input)
    pattern_set = MapSet.new(patterns)
    max_len = patterns |> Enum.map(&String.length/1) |> Enum.max()

    designs
    |> Enum.count(fn design -> count_ways(design, pattern_set, max_len) > 0 end)
  end

  def p2(input) do
    {patterns, designs} = parse(input)
    pattern_set = MapSet.new(patterns)
    max_len = patterns |> Enum.map(&String.length/1) |> Enum.max()

    designs
    |> Enum.map(fn design -> count_ways(design, pattern_set, max_len) end)
    |> Enum.sum()
  end

  defp parse(input) do
    [patterns_line, designs_section] = String.split(input, "\n\n", trim: true)

    patterns = patterns_line |> String.split(", ", trim: true)
    designs = designs_section |> String.split("\n", trim: true)

    {patterns, designs}
  end

  defp count_ways(design, pattern_set, max_len) do
    len = String.length(design)

    # DP array: dp[i] = ways to build first i chars
    dp = :array.new(len + 1, default: 0)
    dp = :array.set(0, 1, dp)  # Base: empty string has 1 way

    dp = Enum.reduce(1..len, dp, fn i, dp ->
      ways =
        for plen <- 1..min(i, max_len),
            pattern = String.slice(design, i - plen, plen),
            MapSet.member?(pattern_set, pattern),
            reduce: 0 do
          acc -> acc + :array.get(i - plen, dp)
        end
      :array.set(i, ways, dp)
    end)

    :array.get(len, dp)
  end
end
