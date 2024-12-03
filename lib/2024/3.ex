import AOC

aoc 2024, 3 do
  @moduledoc """
  https://adventofcode.com/2024/day/3
  """

  @doc """
      iex> p1(example_string())
  """
  def p1(input) do
    input
    |> String.split("mul(")
    |> Enum.map(fn x -> String.split(x, ")") |> hd end)
    |> Enum.map(fn x -> String.split(x, ",") end)
    |> Enum.filter(fn x -> Enum.count(x) == 2 && Enum.all?(x, fn c -> is_integer_string?(c) end) end)
    |> Enum.map(fn [x1, x2] -> String.to_integer(x1) * String.to_integer(x2) end)
    |> Enum.sum()

  end

  def is_integer_string?(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _ -> false
    end
  end

  @doc """
      iex> p2(example_string())
  """
  def p2(input) do
    pattern = ~r/mul\(([0-9]{1,3}),([0-9]{1,3})\)|do\(\)|don't\(\)/
    ops =
      Regex.scan(pattern, input)
      |> Enum.map(fn args ->
        case args do
          ["do()"] -> :do
          ["don't()"] -> :dont
          [_, l, r] -> String.to_integer(l) * String.to_integer(r)
        end
      end)

    ops
    |> Enum.reduce({true, 0}, fn op, {is_on, acc} ->
      case op do
        :do -> {true, acc}
        :dont -> {false, acc}
        n when is_integer(n) and is_on -> {true, acc + n}
        n when is_integer(n) and not(is_on) -> {false, acc}
      end
    end)
    |> elem(1)

  end
end
