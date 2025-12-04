import AOC

aoc 2017, 10 do
  @moduledoc """
  https://adventofcode.com/2017/day/10
  """

  def p1(input) do
    lengths = input |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    list = Enum.to_list(0..255)

    {result, _, _} = knot_hash_round(list, lengths, 0, 0)

    [a, b | _] = result
    a * b
  end

  def p2(input) do
    ascii_lengths = input |> String.trim() |> String.to_charlist()
    lengths = ascii_lengths ++ [17, 31, 73, 47, 23]

    list = Enum.to_list(0..255)

    {sparse_hash, _, _} =
      Enum.reduce(1..64, {list, 0, 0}, fn _, {l, pos, skip} ->
        knot_hash_round(l, lengths, pos, skip)
      end)

    sparse_hash
    |> Enum.chunk_every(16)
    |> Enum.map(fn chunk -> Enum.reduce(chunk, 0, &Bitwise.bxor/2) end)
    |> Enum.map(&String.pad_leading(Integer.to_string(&1, 16), 2, "0"))
    |> Enum.join()
    |> String.downcase()
  end

  defp knot_hash_round(list, lengths, pos, skip) do
    Enum.reduce(lengths, {list, pos, skip}, fn length, {l, p, s} ->
      new_list = reverse_section(l, p, length)
      new_pos = rem(p + length + s, length(l))
      {new_list, new_pos, s + 1}
    end)
  end

  defp reverse_section(list, pos, length) do
    len = length(list)
    indices = Enum.map(0..(length - 1), fn i -> rem(pos + i, len) end)

    section = Enum.map(indices, fn i -> Enum.at(list, i) end) |> Enum.reverse()

    Enum.zip(indices, section)
    |> Enum.reduce(list, fn {idx, val}, acc ->
      List.replace_at(acc, idx, val)
    end)
  end
end
