import AOC

aoc 2019, 6 do
  @moduledoc """
  https://adventofcode.com/2019/day/6
  """

  def p1(input) do
    orbits = parse(input)

    orbits
    |> Map.keys()
    |> Enum.map(fn obj -> count_orbits(orbits, obj) end)
    |> Enum.sum()
  end

  def p2(input) do
    orbits = parse(input)

    you_path = path_to_root(orbits, "YOU")
    san_path = path_to_root(orbits, "SAN")

    # Find common ancestor
    you_set = MapSet.new(you_path)
    common = Enum.find(san_path, fn obj -> MapSet.member?(you_set, obj) end)

    # Distance is YOU->common + SAN->common (minus 2 for YOU and SAN themselves)
    you_dist = Enum.find_index(you_path, fn obj -> obj == common end)
    san_dist = Enum.find_index(san_path, fn obj -> obj == common end)

    you_dist + san_dist - 2
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [parent, child] = String.split(line, ")")
      {child, parent}
    end)
    |> Map.new()
  end

  defp count_orbits(orbits, obj) do
    case Map.get(orbits, obj) do
      nil -> 0
      parent -> 1 + count_orbits(orbits, parent)
    end
  end

  defp path_to_root(orbits, obj) do
    case Map.get(orbits, obj) do
      nil -> [obj]
      parent -> [obj | path_to_root(orbits, parent)]
    end
  end
end
