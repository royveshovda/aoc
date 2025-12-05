import AOC

aoc 2020, 7 do
  @moduledoc """
  https://adventofcode.com/2020/day/7

  Handy Haversacks - Bag containment rules (graph traversal).

  ## Examples

      iex> example = "light red bags contain 1 bright white bag, 2 muted yellow bags.\\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\\nbright white bags contain 1 shiny gold bag.\\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\\nfaded blue bags contain no other bags.\\ndotted black bags contain no other bags."
      iex> Y2020.D7.p1(example)
      4

      iex> example = "light red bags contain 1 bright white bag, 2 muted yellow bags.\\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\\nbright white bags contain 1 shiny gold bag.\\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\\nfaded blue bags contain no other bags.\\ndotted black bags contain no other bags."
      iex> Y2020.D7.p2(example)
      32

      iex> example2 = "shiny gold bags contain 2 dark red bags.\\ndark red bags contain 2 dark orange bags.\\ndark orange bags contain 2 dark yellow bags.\\ndark yellow bags contain 2 dark green bags.\\ndark green bags contain 2 dark blue bags.\\ndark blue bags contain 2 dark violet bags.\\ndark violet bags contain no other bags."
      iex> Y2020.D7.p2(example2)
      126
  """

  def p1(input) do
    rules = parse(input)
    # Build reverse graph: which bags can contain a given bag?
    reverse = build_reverse_graph(rules)
    # BFS/DFS from shiny gold to find all ancestors
    find_ancestors(reverse, "shiny gold")
    |> MapSet.delete("shiny gold")
    |> MapSet.size()
  end

  def p2(input) do
    rules = parse(input)
    # Count bags inside shiny gold (excluding the shiny gold bag itself)
    count_bags_inside(rules, "shiny gold")
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule/1)
    |> Map.new()
  end

  defp parse_rule(line) do
    # "light red bags contain 1 bright white bag, 2 muted yellow bags."
    [container, contents] = String.split(line, " bags contain ")

    contents =
      if contents == "no other bags." do
        []
      else
        contents
        |> String.trim_trailing(".")
        |> String.split(", ")
        |> Enum.map(&parse_content/1)
      end

    {container, contents}
  end

  defp parse_content(content) do
    # "1 bright white bag" or "2 muted yellow bags"
    [count | words] = String.split(content)
    count = String.to_integer(count)
    # Remove "bag" or "bags" from end
    color = words |> Enum.take(length(words) - 1) |> Enum.join(" ")
    {color, count}
  end

  defp build_reverse_graph(rules) do
    Enum.reduce(rules, %{}, fn {container, contents}, acc ->
      Enum.reduce(contents, acc, fn {color, _count}, acc2 ->
        Map.update(acc2, color, [container], &[container | &1])
      end)
    end)
  end

  defp find_ancestors(reverse, start) do
    do_find_ancestors(reverse, [start], MapSet.new([start]))
  end

  defp do_find_ancestors(_reverse, [], visited), do: visited

  defp do_find_ancestors(reverse, [current | rest], visited) do
    parents = Map.get(reverse, current, [])
    new_parents = Enum.reject(parents, &MapSet.member?(visited, &1))
    new_visited = Enum.reduce(new_parents, visited, &MapSet.put(&2, &1))
    do_find_ancestors(reverse, rest ++ new_parents, new_visited)
  end

  defp count_bags_inside(rules, color) do
    contents = Map.get(rules, color, [])

    Enum.reduce(contents, 0, fn {inner_color, count}, acc ->
      acc + count + count * count_bags_inside(rules, inner_color)
    end)
  end
end
