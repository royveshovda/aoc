import AOC

aoc 2015, 16 do
  @moduledoc """
  https://adventofcode.com/2015/day/16

  Day 16: Aunt Sue
  Find which Aunt Sue matches the MFCSAM analysis.
  """

  @target %{
    "children" => 3,
    "cats" => 7,
    "samoyeds" => 2,
    "pomeranians" => 3,
    "akitas" => 0,
    "vizslas" => 0,
    "goldfish" => 5,
    "trees" => 3,
    "cars" => 2,
    "perfumes" => 1
  }

  @doc """
  Part 1: Find the Aunt Sue that matches all known attributes exactly.
  """
  def p1(input) do
    input
    |> parse_aunts()
    |> Enum.find(fn {_num, attrs} -> matches_exactly?(attrs) end)
    |> elem(0)
  end

  @doc """
  Part 2: Find Aunt Sue with updated matching rules:
  - cats and trees: reading indicates greater than the target
  - pomeranians and goldfish: reading indicates fewer than the target
  - Everything else: must match exactly
  """
  def p2(input) do
    input
    |> parse_aunts()
    |> Enum.find(fn {_num, attrs} -> matches_with_ranges?(attrs) end)
    |> elem(0)
  end

  defp parse_aunts(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Example: "Sue 1: children: 1, cars: 8, vizslas: 7"
    [sue_part, attrs_part] = String.split(line, ": ", parts: 2)
    sue_num = sue_part |> String.split(" ") |> List.last() |> String.to_integer()

    attrs =
      attrs_part
      |> String.split(", ")
      |> Enum.map(fn attr ->
        [key, value] = String.split(attr, ": ")
        {key, String.to_integer(value)}
      end)
      |> Map.new()

    {sue_num, attrs}
  end

  defp matches_exactly?(attrs) do
    Enum.all?(attrs, fn {key, value} ->
      Map.get(@target, key) == value
    end)
  end

  defp matches_with_ranges?(attrs) do
    Enum.all?(attrs, fn {key, value} ->
      target_value = Map.get(@target, key)

      cond do
        key in ["cats", "trees"] -> value > target_value
        key in ["pomeranians", "goldfish"] -> value < target_value
        true -> value == target_value
      end
    end)
  end
end
