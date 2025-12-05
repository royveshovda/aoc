import AOC

aoc 2020, 19 do
  @moduledoc """
  https://adventofcode.com/2020/day/19

  Monster Messages - Grammar matching with recursive rules.

  ## Examples

      iex> example = "0: 4 1 5\\n1: 2 3 | 3 2\\n2: 4 4 | 5 5\\n3: 4 5 | 5 4\\n4: \\"a\\"\\n5: \\"b\\"\\n\\nababbb\\nbababa\\nabbbab\\naaabbb\\naaaabbb"
      iex> Y2020.D19.p1(example)
      2
  """

  def p1(input) do
    {rules, messages} = parse(input)
    count_matches(rules, messages)
  end

  def p2(input) do
    {rules, messages} = parse(input)

    # Update rules 8 and 11 for Part 2
    # 8: 42 | 42 8  -> one or more 42
    # 11: 42 31 | 42 11 31 -> n times 42 followed by n times 31
    rules =
      rules
      |> Map.put(8, {:or, [[42], [42, 8]]})
      |> Map.put(11, {:or, [[42, 31], [42, 11, 31]]})

    count_matches(rules, messages)
  end

  defp parse(input) do
    [rules_section, messages_section] = String.split(input, "\n\n", trim: true)

    rules =
      rules_section
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_rule/1)
      |> Map.new()

    messages = String.split(messages_section, "\n", trim: true)

    {rules, messages}
  end

  defp parse_rule(line) do
    [id_str, rule_str] = String.split(line, ": ")
    id = String.to_integer(id_str)

    rule =
      cond do
        String.contains?(rule_str, "\"") ->
          # Terminal: "a" or "b"
          {:char, String.trim(rule_str, "\"")}

        String.contains?(rule_str, "|") ->
          # Alternation
          alternatives =
            rule_str
            |> String.split(" | ")
            |> Enum.map(&parse_sequence/1)

          {:or, alternatives}

        true ->
          # Simple sequence
          {:seq, parse_sequence(rule_str)}
      end

    {id, rule}
  end

  defp parse_sequence(str) do
    str
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp count_matches(rules, messages) do
    Enum.count(messages, fn msg ->
      matches?(rules, 0, String.graphemes(msg))
    end)
  end

  # Returns true if the entire input matches rule 0
  defp matches?(rules, rule_id, chars) do
    case match_rule(rules, rule_id, chars) do
      {:ok, remainders} ->
        # Check if any path consumed the entire string
        Enum.any?(remainders, &(&1 == []))

      :error ->
        false
    end
  end

  # Returns {:ok, list_of_remainders} or :error
  # Each remainder is the unconsumed part of the input after matching
  defp match_rule(_rules, _rule_id, []), do: :error

  defp match_rule(rules, rule_id, chars) do
    case Map.get(rules, rule_id) do
      {:char, c} ->
        case chars do
          [^c | rest] -> {:ok, [rest]}
          _ -> :error
        end

      {:seq, seq} ->
        match_sequence(rules, seq, [chars])

      {:or, alternatives} ->
        results =
          alternatives
          |> Enum.flat_map(fn seq ->
            case match_sequence(rules, seq, [chars]) do
              {:ok, remainders} -> remainders
              :error -> []
            end
          end)

        if results == [], do: :error, else: {:ok, results}
    end
  end

  # Match a sequence of rule IDs against multiple possible inputs
  defp match_sequence(_rules, [], inputs), do: {:ok, inputs}

  defp match_sequence(_rules, _seq, []), do: :error

  defp match_sequence(rules, [rule_id | rest_rules], inputs) do
    new_inputs =
      inputs
      |> Enum.flat_map(fn chars ->
        case match_rule(rules, rule_id, chars) do
          {:ok, remainders} -> remainders
          :error -> []
        end
      end)

    if new_inputs == [] do
      :error
    else
      match_sequence(rules, rest_rules, new_inputs)
    end
  end
end
