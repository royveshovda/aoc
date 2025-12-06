import AOC

aoc 2021, 14 do
  @moduledoc """
  Day 14: Extended Polymerization

  Grow polymer by inserting elements between pairs.
  Key insight: Track pair counts, not the actual string.
  """

  @doc """
  Part 1: After 10 steps, most common - least common element count.

  ## Examples

      iex> p1("NNCB\\n\\nCH -> B\\nHH -> N\\nCB -> H\\nNH -> C\\nHB -> C\\nHC -> B\\nHN -> C\\nNN -> C\\nBH -> H\\nNC -> B\\nNB -> B\\nBN -> B\\nBB -> N\\nBC -> B\\nCC -> N\\nCN -> C")
      1588
  """
  def p1(input) do
    {template, rules} = parse(input)
    solve(template, rules, 10)
  end

  @doc """
  Part 2: After 40 steps, most common - least common element count.

  ## Examples

      iex> p2("NNCB\\n\\nCH -> B\\nHH -> N\\nCB -> H\\nNH -> C\\nHB -> C\\nHC -> B\\nHN -> C\\nNN -> C\\nBH -> H\\nNC -> B\\nNB -> B\\nBN -> B\\nBB -> N\\nBC -> B\\nCC -> N\\nCN -> C")
      2188189693529
  """
  def p2(input) do
    {template, rules} = parse(input)
    solve(template, rules, 40)
  end

  defp solve(template, rules, steps) do
    # Convert template to pair counts
    pairs =
      template
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&List.to_tuple/1)
      |> Enum.frequencies()

    # Apply steps
    final_pairs = Enum.reduce(1..steps, pairs, fn _, p -> step(p, rules) end)

    # Count elements (each element appears in 2 pairs except first and last)
    element_counts =
      final_pairs
      |> Enum.reduce(%{}, fn {{a, b}, count}, acc ->
        acc
        |> Map.update(a, count, &(&1 + count))
        |> Map.update(b, count, &(&1 + count))
      end)
      |> Map.new(fn {k, v} -> {k, v} end)

    # Each element is counted twice except first and last
    first = hd(template)
    last = List.last(template)

    element_counts =
      element_counts
      |> Map.update(first, 0, &(&1 + 1))
      |> Map.update(last, 0, &(&1 + 1))
      |> Map.new(fn {k, v} -> {k, div(v, 2)} end)

    {min, max} = element_counts |> Map.values() |> Enum.min_max()
    max - min
  end

  defp step(pairs, rules) do
    Enum.reduce(pairs, %{}, fn {{a, b} = pair, count}, acc ->
      case Map.get(rules, pair) do
        nil ->
          Map.update(acc, pair, count, &(&1 + count))

        insert ->
          acc
          |> Map.update({a, insert}, count, &(&1 + count))
          |> Map.update({insert, b}, count, &(&1 + count))
      end
    end)
  end

  defp parse(input) do
    [template_line, rules_section] = String.split(input, "\n\n", trim: true)

    template = String.graphemes(template_line)

    rules =
      rules_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [pair, insert] = String.split(line, " -> ")
        [a, b] = String.graphemes(pair)
        {{a, b}, insert}
      end)
      |> Map.new()

    {template, rules}
  end
end
