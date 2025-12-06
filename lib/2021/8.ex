import AOC

aoc 2021, 8 do
  @moduledoc """
  Day 8: Seven Segment Search

  Decode scrambled seven-segment displays.
  Part 1: Count digits with unique segment counts (1,4,7,8)
  Part 2: Decode all output values
  """

  @doc """
  Part 1: Count outputs with lengths 2 (1), 3 (7), 4 (4), or 7 (8).

  ## Examples

      iex> p1("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\\nedbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\\nfgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\\nfbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\\naecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\\nfgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\\ndbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\\nbdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\\negadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\\ngcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce")
      26
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.flat_map(fn {_patterns, outputs} -> outputs end)
    |> Enum.count(&(String.length(&1) in [2, 3, 4, 7]))
  end

  @doc """
  Part 2: Decode all output values and sum them.

  ## Examples

      iex> p2("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\\nedbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\\nfgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\\nfbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\\naecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\\nfgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\\ndbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\\nbdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\\negadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\\ngcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce")
      61229
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&decode_line/1)
    |> Enum.sum()
  end

  defp decode_line({patterns, outputs}) do
    mapping = deduce_mapping(patterns)

    outputs
    |> Enum.map(&decode_digit(&1, mapping))
    |> Integer.undigits()
  end

  defp deduce_mapping(patterns) do
    patterns = Enum.map(patterns, &to_set/1)

    # Find digits with unique lengths
    one = Enum.find(patterns, &(MapSet.size(&1) == 2))
    four = Enum.find(patterns, &(MapSet.size(&1) == 4))
    seven = Enum.find(patterns, &(MapSet.size(&1) == 3))
    eight = Enum.find(patterns, &(MapSet.size(&1) == 7))

    # 6-segment digits: 0, 6, 9
    six_segments = Enum.filter(patterns, &(MapSet.size(&1) == 6))

    # 6 is the only 6-segment that doesn't contain both segments of 1
    six = Enum.find(six_segments, &(!MapSet.subset?(one, &1)))

    # 9 contains all of 4, 0 doesn't
    nine = Enum.find(six_segments, &(&1 != six and MapSet.subset?(four, &1)))
    zero = Enum.find(six_segments, &(&1 != six and &1 != nine))

    # 5-segment digits: 2, 3, 5
    five_segments = Enum.filter(patterns, &(MapSet.size(&1) == 5))

    # 3 contains both segments of 1
    three = Enum.find(five_segments, &MapSet.subset?(one, &1))

    # 5 is subset of 6, 2 is not
    five = Enum.find(five_segments, &(&1 != three and MapSet.subset?(&1, six)))
    two = Enum.find(five_segments, &(&1 != three and &1 != five))

    %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9
    }
  end

  defp decode_digit(pattern, mapping) do
    Map.get(mapping, to_set(pattern))
  end

  defp to_set(pattern) do
    pattern
    |> String.graphemes()
    |> MapSet.new()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [patterns, outputs] = String.split(line, " | ")
      {String.split(patterns), String.split(outputs)}
    end)
  end
end
