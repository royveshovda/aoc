import AOC

aoc 2021, 10 do
  @moduledoc """
  Day 10: Syntax Scoring

  Parse bracket sequences.
  Part 1: Score corrupted lines (wrong closing bracket)
  Part 2: Score incomplete lines (missing closing brackets)
  """

  @pairs %{"(" => ")", "[" => "]", "{" => "}", "<" => ">"}
  @openers MapSet.new(["(", "[", "{", "<"])

  @error_scores %{")" => 3, "]" => 57, "}" => 1197, ">" => 25137}
  @completion_scores %{")" => 1, "]" => 2, "}" => 3, ">" => 4}

  @doc """
  Part 1: Find corrupted lines and sum their error scores.

  ## Examples

      iex> p1("[({(<(())[]>[[{[]{<()<>>\\n[(()[<>])]({[<{<<[]>>(\\n{([(<{}[<>[]}>{[]{[(<()>\\n(((({<>}<{<{<>}{[]{[]{}\\n[[<[([]))<([[{}[[()]]]\\n[{[{({}]{}}([{[{{{}}([]\\n{<[[]]>}<{[{[{[]{()[[[]\\n[<(<(<(<{}))><([]([]()\\n<{([([[(<>()){}]>(<<{{\\n<{([{{}}[<[[[<>{}]]]>[]]")
      26397
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&check_line/1)
    |> Enum.filter(&match?({:corrupted, _}, &1))
    |> Enum.map(fn {:corrupted, char} -> Map.get(@error_scores, char) end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Find incomplete lines, complete them, and find middle score.

  ## Examples

      iex> p2("[({(<(())[]>[[{[]{<()<>>\\n[(()[<>])]({[<{<<[]>>(\\n{([(<{}[<>[]}>{[]{[(<()>\\n(((({<>}<{<{<>}{[]{[]{}\\n[[<[([]))<([[{}[[()]]]\\n[{[{({}]{}}([{[{{{}}([]\\n{<[[]]>}<{[{[{[]{()[[[]\\n[<(<(<(<{}))><([]([]()\\n<{([([[(<>()){}]>(<<{{\\n<{([{{}}[<[[[<>{}]]]>[]]")
      288957
  """
  def p2(input) do
    scores =
      input
      |> parse()
      |> Enum.map(&check_line/1)
      |> Enum.filter(&match?({:incomplete, _}, &1))
      |> Enum.map(fn {:incomplete, stack} -> completion_score(stack) end)
      |> Enum.sort()

    Enum.at(scores, div(length(scores), 2))
  end

  defp check_line(chars), do: check_line(chars, [])

  defp check_line([], []), do: :ok
  defp check_line([], stack), do: {:incomplete, stack}

  defp check_line([char | rest], stack) do
    cond do
      MapSet.member?(@openers, char) ->
        check_line(rest, [char | stack])

      true ->
        case stack do
          [] ->
            {:corrupted, char}

          [opener | rest_stack] ->
            if Map.get(@pairs, opener) == char do
              check_line(rest, rest_stack)
            else
              {:corrupted, char}
            end
        end
    end
  end

  defp completion_score(stack) do
    stack
    |> Enum.map(&Map.get(@pairs, &1))
    |> Enum.reduce(0, fn char, acc ->
      acc * 5 + Map.get(@completion_scores, char)
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end
