import AOC

aoc 2024, 7 do
  @moduledoc """
  https://adventofcode.com/2024/day/7

  Bridge Repair - Find equations solvable with +, *, and || operators.
  """

  def p1(input) do
    input
    |> parse()
    |> Enum.filter(fn {target, nums} -> solvable?(target, nums, [:add, :mul]) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> Enum.filter(fn {target, nums} -> solvable?(target, nums, [:add, :mul, :concat]) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [target, nums] = String.split(line, ": ")
      {String.to_integer(target), nums |> String.split() |> Enum.map(&String.to_integer/1)}
    end)
  end

  defp solvable?(target, [first | rest], ops) do
    check(target, rest, first, ops)
  end

  defp check(target, [], acc, _ops), do: acc == target
  defp check(target, _, acc, _ops) when acc > target, do: false
  defp check(target, [n | rest], acc, ops) do
    Enum.any?(ops, fn op ->
      new_acc = apply_op(op, acc, n)
      check(target, rest, new_acc, ops)
    end)
  end

  defp apply_op(:add, a, b), do: a + b
  defp apply_op(:mul, a, b), do: a * b
  defp apply_op(:concat, a, b) do
    digits = if b == 0, do: 1, else: trunc(:math.log10(b)) + 1
    a * trunc(:math.pow(10, digits)) + b
  end
end
