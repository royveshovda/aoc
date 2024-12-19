import AOC

aoc 2024, 19 do
  @moduledoc """
  https://adventofcode.com/2024/day/19
  """

  def p1(input) do
    {towel_patterns, designs} = parse(input)

    designs
    |> Enum.count(&can_form?(&1, towel_patterns))
  end

  def p2(input) do
    {towel_patterns, designs} = parse(input)
    total_ways =
      designs
      |> Enum.map(&num_ways(&1, towel_patterns))
      |> Enum.sum()

    total_ways
  end

  def parse(input) do
    [patterns_line, designs_text] = String.split(input, "\n\n", parts: 2)
    towel_patterns = String.split(patterns_line, ",") |> Enum.map(&String.trim/1)
    designs = String.split(designs_text, "\n", trim: true)
    {towel_patterns, designs}
  end

  def can_form?(design, patterns) do
    len = String.length(design)
    dp = Map.new()
    dp = Map.put(dp, 0, true)

    dp =
      Enum.reduce(1..len, dp, fn i, dp ->
        found =
          Enum.any?(patterns, fn pattern ->
            pattern_length = String.length(pattern)
            if i >= pattern_length do
              prev = Map.get(dp, i - pattern_length, false)
              prev and pattern == String.slice(design, i - pattern_length, pattern_length)
            else
              false
            end
          end)

        if found do
          Map.put(dp, i, true)
        else
          dp
        end
      end)

    Map.get(dp, len, false)
  end

  def num_ways(design, patterns) do
    len = String.length(design)
    dp = %{0 => 1}

    dp =
      Enum.reduce(1..len, dp, fn pos, dp_acc ->
        total =
          Enum.reduce(patterns, 0, fn pattern, acc ->
            plen = String.length(pattern)

            if pos >= plen and String.slice(design, pos - plen, plen) == pattern do
              acc + Map.get(dp_acc, pos - plen, 0)
            else
              acc
            end
          end)

        Map.put(dp_acc, pos, total)
      end)

    Map.get(dp, len, 0)
  end
end
