import AOC

aoc 2025, 5 do
  @moduledoc """
  https://adventofcode.com/2025/day/5
  """

  @doc """
      iex> p1(example_string(0))
      3
  """
  def p1(input) do
    {ranges, ingredients} = parse(input)

    ingredients
    |> Enum.count(fn id -> is_fresh?(id, ranges) end)
  end

  @doc """
      iex> p2(example_string(0))
      14
  """
  def p2(input) do
    {ranges, _ingredients} = parse(input)

    ranges
    |> merge_ranges()
    |> Enum.map(fn {a, b} -> b - a + 1 end)
    |> Enum.sum()
  end

  defp parse(input) do
    [ranges_section, ingredients_section] = String.split(input, "\n\n", trim: true)

    ranges =
      ranges_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [a, b] = String.split(line, "-")
        {String.to_integer(a), String.to_integer(b)}
      end)

    ingredients =
      ingredients_section
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {ranges, ingredients}
  end

  defp is_fresh?(id, ranges) do
    Enum.any?(ranges, fn {a, b} -> id >= a and id <= b end)
  end

  defp merge_ranges(ranges) do
    ranges
    |> Enum.sort()
    |> Enum.reduce([], fn {a, b}, acc ->
      case acc do
        [] -> [{a, b}]
        [{prev_a, prev_b} | rest] ->
          if a <= prev_b + 1 do
            # Overlapping or adjacent, merge them
            [{prev_a, max(prev_b, b)} | rest]
          else
            # No overlap, add new range
            [{a, b}, {prev_a, prev_b} | rest]
          end
      end
    end)
  end
end
