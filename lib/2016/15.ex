import AOC

aoc 2016, 15 do
  @moduledoc """
  https://adventofcode.com/2016/day/15
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    discs = parse(input)
    find_time(discs)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    discs = parse(input)
    extra_disc = {length(discs) + 1, 11, 0}
    find_time(discs ++ [extra_disc])
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(fn {line, disc_num} ->
      ~r/has (\d+) positions.*at position (\d+)/
      |> Regex.run(line)
      |> then(fn [_, positions, start] ->
        {disc_num, String.to_integer(positions), String.to_integer(start)}
      end)
    end)
  end

  defp find_time(discs) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(fn t ->
      Enum.all?(discs, fn {disc_num, positions, start} ->
        rem(start + t + disc_num, positions) == 0
      end)
    end)
  end
end
