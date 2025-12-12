import AOC

aoc 2025, 12 do
  @moduledoc """
  https://adventofcode.com/2025/day/12
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    blocks = String.split(input, "\n\n", trim: true)

    {shape_blocks, region_blocks} = Enum.split_with(blocks, fn block ->
      first_line = block |> String.split("\n") |> List.first()
      !String.contains?(first_line, "x")
    end)

    shapes =
      shape_blocks
      |> Enum.map(fn block ->
        [header | grid] = String.split(block, "\n", trim: true)
        {id, _} = Integer.parse(header)
        area = grid |> Enum.join() |> String.graphemes() |> Enum.count(&(&1 == "#"))
        {id, area}
      end)
      |> Enum.sort_by(fn {id, _} -> id end)
      |> Enum.map(fn {_, area} -> area end)

    region_blocks
    |> Enum.join("\n")
    |> String.split("\n", trim: true)
    |> Enum.count(fn line ->
      [dims, counts_str] = String.split(line, ": ")
      [w, h] = String.split(dims, "x") |> Enum.map(&String.to_integer/1)

      counts =
        counts_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      total_present_area =
        Enum.zip(counts, shapes)
        |> Enum.map(fn {count, area} -> count * area end)
        |> Enum.sum()

      w * h >= total_present_area
    end)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    input
  end
end
