import AOC

aoc 2024, 25 do
  @moduledoc """
  https://adventofcode.com/2024/day/25

  Code Chronicle - Count lock/key pairs that fit without overlap.
  """

  def p1(input) do
    {locks, keys} = parse(input)

    for lock <- locks,
        key <- keys,
        fits?(lock, key),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  def p2(_input) do
    # Day 25 Part 2 is always free!
    "⭐"
  end

  defp parse(input) do
    schematics = String.split(input, "\n\n", trim: true)

    {locks, keys} =
      schematics
      |> Enum.map(&parse_schematic/1)
      |> Enum.split_with(fn {type, _} -> type == :lock end)

    {Enum.map(locks, &elem(&1, 1)), Enum.map(keys, &elem(&1, 1))}
  end

  defp parse_schematic(block) do
    lines = String.split(block, "\n", trim: true)

    type = if String.at(hd(lines), 0) == "#", do: :lock, else: :key

    # Count filled cells per column
    heights =
      lines
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip_with(& &1)  # Transpose
      |> Enum.map(fn col -> Enum.count(col, &(&1 == "#")) - 1 end)

    {type, heights}
  end

  defp fits?(lock, key) do
    Enum.zip(lock, key)
    |> Enum.all?(fn {l, k} -> l + k <= 5 end)
  end
end
