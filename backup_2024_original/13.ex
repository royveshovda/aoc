import AOC

aoc 2024, 13 do
  @moduledoc """
  https://adventofcode.com/2024/day/13
  """

  def p1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn [a, b, p] -> {parse_button(a), parse_button(b), parse_price(p)} end)
    |> Enum.map(&solve/1)
    |> Enum.map(fn {a, b} -> 3 * a + b end)
    |> Enum.sum()

  end

  def solve({{x1, y1}, {x2, y2}, {prize_x, prize_y}}) do
    a = (prize_x * y2 - prize_y * x2) / (x1 * y2 - y1 * x2)
    b = (prize_y * x1 - prize_x * y1) / (x1 * y2 - y1 * x2)

    if a == trunc(a) and b == trunc(b) do
      {trunc(a), trunc(b)}
    else
      {0, 0}
    end
  end

  def parse_button(button) do
    [_, _, x, _, y] = String.split(button, ["+", ",", ":"], trim: true)
    x = String.to_integer(x)
    y = String.to_integer(y)
    {x, y}
  end

  def parse_price(price) do
    [_, _, target_x, _, target_y] = String.split(price, ["=", ",", ":"], trim: true)
    target_x = String.to_integer(target_x)
    target_y = String.to_integer(target_y)
    {target_x, target_y}
  end

  def p2(input) do
    add = 10_000_000_000_000
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn [a, b, p] -> {parse_button(a), parse_button(b), parse_price(p)} end)
    |> Enum.map(fn {a, b, {p_x, p_y}} -> {a, b, {(p_x + add), (p_y + add)}} end)
    |> Enum.map(&solve/1)
    |> Enum.map(fn {a, b} -> 3 * a + b end)
    |> Enum.sum()
  end
end
