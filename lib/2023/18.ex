import AOC

aoc 2023, 18 do
  @moduledoc """
  https://adventofcode.com/2023/day/18
  """

  @doc """
      iex> p1(example_string())
      123

      #iex> p1(input_string())
      #123
  """
  def p1(input) do
    input
    |> parse_input()
  end

  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse_input()
  end

  def parse_input(input) do
    input
    |> String.split("\n")
  end
end
