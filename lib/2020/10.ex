import AOC

aoc 2020, 10 do
  @moduledoc """
  https://adventofcode.com/2020/day/10

  Adapter Array - Chain adapters, count arrangements (dynamic programming).

  ## Examples

      iex> example = "16\\n10\\n15\\n5\\n1\\n11\\n7\\n19\\n6\\n12\\n4"
      iex> Y2020.D10.p1(example)
      35

      iex> example2 = "28\\n33\\n18\\n42\\n31\\n14\\n46\\n20\\n48\\n47\\n24\\n23\\n49\\n45\\n19\\n38\\n39\\n11\\n1\\n32\\n25\\n35\\n8\\n17\\n7\\n9\\n4\\n2\\n34\\n10\\n3"
      iex> Y2020.D10.p1(example2)
      220

      iex> example = "16\\n10\\n15\\n5\\n1\\n11\\n7\\n19\\n6\\n12\\n4"
      iex> Y2020.D10.p2(example)
      8

      iex> example2 = "28\\n33\\n18\\n42\\n31\\n14\\n46\\n20\\n48\\n47\\n24\\n23\\n49\\n45\\n19\\n38\\n39\\n11\\n1\\n32\\n25\\n35\\n8\\n17\\n7\\n9\\n4\\n2\\n34\\n10\\n3"
      iex> Y2020.D10.p2(example2)
      19208
  """

  def p1(input) do
    adapters = parse(input)
    # Add outlet (0) and device (max + 3)
    chain = [0 | adapters] ++ [Enum.max(adapters) + 3]
    chain = Enum.sort(chain)

    # Count differences
    diffs =
      chain
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)
      |> Enum.frequencies()

    Map.get(diffs, 1, 0) * Map.get(diffs, 3, 0)
  end

  def p2(input) do
    adapters = parse(input)
    # Add outlet (0) and device (max + 3)
    device = Enum.max(adapters) + 3
    chain = [0 | adapters] ++ [device]
    adapter_set = MapSet.new(chain)

    # DP: count ways to reach each adapter
    # ways[j] = sum of ways[i] for all i where j-i <= 3 and i is a valid adapter
    chain
    |> Enum.sort()
    |> Enum.reduce(%{0 => 1}, fn jolt, ways ->
      if jolt == 0 do
        ways
      else
        count =
          1..3
          |> Enum.filter(&MapSet.member?(adapter_set, jolt - &1))
          |> Enum.map(&Map.get(ways, jolt - &1, 0))
          |> Enum.sum()

        Map.put(ways, jolt, count)
      end
    end)
    |> Map.get(device)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
