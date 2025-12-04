import AOC

aoc 2015, 1 do
  @moduledoc """
  https://adventofcode.com/2015/day/1

  Day 1: Not Quite Lisp
  Santa needs to find the right floor in an apartment building.
  - '(' means go up one floor
  - ')' means go down one floor
  - He starts at floor 0
  """

  @doc """
  Part 1: What floor does Santa end up on?

  Examples:
  - "(())" and "()()" result in floor 0
  - "(((" and "(()(()(" result in floor 3
  - "))(((((" also results in floor 3
  - "())" and "))(" result in floor -1
  - ")))" and ")())())" result in floor -3

      iex> p1("(())")
      0

      iex> p1("()()")
      0

      iex> p1("(((")
      3

      iex> p1("(()(()(")
      3

      iex> p1("))(")
      -1

      iex> p1(")))")
      -3
  """
  def p1(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce(0, fn
      "(", floor -> floor + 1
      ")", floor -> floor - 1
      _, floor -> floor  # Ignore any other characters
    end)
  end

  @doc """
  Part 2: Find the position of the first character that causes Santa
  to enter the basement (floor -1).

      iex> p2(")")
      1

      iex> p2("()())")
      5
  """
  def p2(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index(1)  # 1-indexed positions
    |> Enum.reduce_while(0, fn
      {"(", position}, floor ->
        new_floor = floor + 1
        if new_floor == -1, do: {:halt, position}, else: {:cont, new_floor}

      {")", position}, floor ->
        new_floor = floor - 1
        if new_floor == -1, do: {:halt, position}, else: {:cont, new_floor}

      {_, _position}, floor ->
        {:cont, floor}  # Ignore other characters
    end)
  end
end
