import AOC

aoc 2017, 5 do
  @moduledoc """
  https://adventofcode.com/2017/day/5
  """

  def p1(input) do
    jumps = parse(input)
    execute(jumps, 0, 0, &(&1 + 1))
  end

  def p2(input) do
    jumps = parse(input)
    execute(jumps, 0, 0, fn offset -> if offset >= 3, do: offset - 1, else: offset + 1 end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {val, idx} -> {idx, val} end)
  end

  defp execute(jumps, pos, steps, update_fn) do
    case Map.get(jumps, pos) do
      nil -> steps
      offset ->
        new_jumps = Map.put(jumps, pos, update_fn.(offset))
        execute(new_jumps, pos + offset, steps + 1, update_fn)
    end
  end
end
