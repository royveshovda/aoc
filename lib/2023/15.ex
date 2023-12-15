import AOC

aoc 2023, 15 do
  @moduledoc """
  https://adventofcode.com/2023/day/15
  """

  @doc """
      iex> p1(example_string())
      1320

      iex> p1(input_string())
      505379
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      line
      |> run_hash()
    end)
    |> Enum.sum()
  end

  def run_hash(string) do
    vals = to_charlist(string)
    Enum.reduce(vals, 0, fn val, acc ->
      s1 = acc + val
      s2 = s1 * 17
      s3 = rem(s2, 256)
      s3
    end)
  end

  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse()
  end

  def parse(input) do
    input
    |> String.split(",")
  end
end
