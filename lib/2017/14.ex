import AOC

aoc 2017, 14 do
  @moduledoc """
  https://adventofcode.com/2017/day/14
  """

  def p1(input) do
    key = String.trim(input)

    0..127
    |> Enum.map(fn row ->
      "#{key}-#{row}"
      |> knot_hash()
      |> hex_to_binary()
      |> String.graphemes()
      |> Enum.count(&(&1 == "1"))
    end)
    |> Enum.sum()
  end

  def p2(input) do
    key = String.trim(input)

    grid =
      0..127
      |> Enum.flat_map(fn row ->
        "#{key}-#{row}"
        |> knot_hash()
        |> hex_to_binary()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {bit, _} -> bit == "1" end)
        |> Enum.map(fn {_, col} -> {row, col} end)
      end)
      |> MapSet.new()

    count_regions(grid)
  end

  defp knot_hash(input) do
    lengths = String.to_charlist(input) ++ [17, 31, 73, 47, 23]
    list = Enum.to_list(0..255)

    {sparse, _, _} =
      Enum.reduce(1..64, {list, 0, 0}, fn _, {l, pos, skip} ->
        knot_round(l, lengths, pos, skip)
      end)

    sparse
    |> Enum.chunk_every(16)
    |> Enum.map(fn chunk -> Enum.reduce(chunk, 0, &Bitwise.bxor/2) end)
    |> Enum.map(&String.pad_leading(Integer.to_string(&1, 16), 2, "0"))
    |> Enum.join()
    |> String.downcase()
  end

  defp knot_round(list, lengths, pos, skip) do
    Enum.reduce(lengths, {list, pos, skip}, fn length, {l, p, s} ->
      new_list = reverse_section(l, p, length)
      {new_list, rem(p + length + s, length(l)), s + 1}
    end)
  end

  defp reverse_section(list, pos, length) do
    len = length(list)
    indices = Enum.map(0..(length - 1), fn i -> rem(pos + i, len) end)
    section = Enum.map(indices, &Enum.at(list, &1)) |> Enum.reverse()

    Enum.zip(indices, section)
    |> Enum.reduce(list, fn {idx, val}, acc -> List.replace_at(acc, idx, val) end)
  end

  defp hex_to_binary(hex) do
    hex
    |> String.graphemes()
    |> Enum.map(fn c ->
      {val, ""} = Integer.parse(c, 16)
      val |> Integer.to_string(2) |> String.pad_leading(4, "0")
    end)
    |> Enum.join()
  end

  defp count_regions(grid) do
    count_regions(grid, MapSet.new(), 0)
  end

  defp count_regions(grid, visited, count) do
    case MapSet.difference(grid, visited) |> Enum.take(1) do
      [] -> count
      [start] ->
        region = flood_fill(grid, start, MapSet.new())
        count_regions(grid, MapSet.union(visited, region), count + 1)
    end
  end

  defp flood_fill(grid, pos, visited) do
    if MapSet.member?(visited, pos) or not MapSet.member?(grid, pos) do
      visited
    else
      {r, c} = pos
      new_visited = MapSet.put(visited, pos)

      [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
      |> Enum.reduce(new_visited, fn neighbor, acc ->
        flood_fill(grid, neighbor, acc)
      end)
    end
  end
end
