import AOC

aoc 2017, 6 do
  @moduledoc """
  https://adventofcode.com/2017/day/6
  """

  def p1(input) do
    banks = parse(input)
    {cycles, _} = find_cycle(banks)
    cycles
  end

  def p2(input) do
    banks = parse(input)
    {_, loop_size} = find_cycle(banks)
    loop_size
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp find_cycle(banks) do
    find_cycle(banks, %{}, 0)
  end

  defp find_cycle(banks, seen, count) do
    key = :erlang.phash2(banks)

    case Map.get(seen, key) do
      nil ->
        new_banks = redistribute(banks)
        find_cycle(new_banks, Map.put(seen, key, count), count + 1)

      first_seen ->
        {count, count - first_seen}
    end
  end

  defp redistribute(banks) do
    max_blocks = Enum.max(banks)
    idx = Enum.find_index(banks, &(&1 == max_blocks))

    banks
    |> List.replace_at(idx, 0)
    |> distribute(idx + 1, max_blocks)
  end

  defp distribute(banks, _pos, 0), do: banks

  defp distribute(banks, pos, remaining) do
    idx = rem(pos, length(banks))
    new_banks = List.update_at(banks, idx, &(&1 + 1))
    distribute(new_banks, pos + 1, remaining - 1)
  end
end
