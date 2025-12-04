import AOC

aoc 2015, 13 do
  @moduledoc """
  https://adventofcode.com/2015/day/13

  Day 13: Knights of the Dinner Table
  Find optimal circular seating arrangement to maximize happiness.
  """

  @doc """
  Part 1: Find the maximum total happiness for circular seating.

  Example optimal arrangement: David-Alice-Bob-Carol (330 happiness)

      iex> p1(example_string(0))
      330
  """
  def p1(input) do
    {happiness_map, people} = parse_happiness(input)
    find_optimal_happiness(happiness_map, people)
  end

  @doc """
  Part 2: Add yourself to the table with 0 happiness change for everyone.
  Find the new maximum total happiness.
  """
  def p2(input) do
    {happiness_map, people} = parse_happiness(input)

    # Add yourself with 0 happiness to/from everyone
    happiness_map_with_me =
      Enum.reduce(people, happiness_map, fn person, acc ->
        acc
        |> Map.put({"Me", person}, 0)
        |> Map.put({person, "Me"}, 0)
      end)

    people_with_me = ["Me" | people]
    find_optimal_happiness(happiness_map_with_me, people_with_me)
  end

  defp parse_happiness(input) do
    lines = String.split(input, "\n", trim: true)

    happiness_map =
      lines
      |> Enum.map(&parse_line/1)
      |> Map.new()

    people =
      lines
      |> Enum.flat_map(fn line ->
        {{person1, person2}, _value} = parse_line(line)
        [person1, person2]
      end)
      |> Enum.uniq()

    {happiness_map, people}
  end

  defp parse_line(line) do
    # Example: "Alice would gain 54 happiness units by sitting next to Bob."
    regex = ~r/^(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\.$/
    [person1, gain_lose, amount, person2] = Regex.run(regex, line, capture: :all_but_first)

    value = String.to_integer(amount)
    value = if gain_lose == "lose", do: -value, else: value

    {{person1, person2}, value}
  end

  defp find_optimal_happiness(happiness_map, people) do
    # For circular arrangement, fix first person to avoid counting rotations as different
    [first | rest] = people

    rest
    |> permutations()
    |> Enum.map(fn arrangement ->
      calculate_circular_happiness([first | arrangement], happiness_map)
    end)
    |> Enum.max()
  end

  defp calculate_circular_happiness(arrangement, happiness_map) do
    # For circular table, add connection from last to first
    circular = arrangement ++ [hd(arrangement)]

    circular
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [person1, person2] ->
      # Bidirectional happiness
      Map.get(happiness_map, {person1, person2}, 0) +
      Map.get(happiness_map, {person2, person1}, 0)
    end)
    |> Enum.sum()
  end

  defp permutations([]), do: [[]]
  defp permutations(list) do
    for elem <- list,
        rest <- permutations(list -- [elem]),
        do: [elem | rest]
  end
end
