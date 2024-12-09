import AOC

aoc 2024, 7 do
  @moduledoc """
  https://adventofcode.com/2024/day/7
  """

  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      [res, values] = String.split(l, ":", trim: true)
      res = String.to_integer(res)
      values = String.split(values, " ", trim: true) |> Enum.map(fn v -> String.to_integer(v) end)
      {res, values}
    end)
    |> Enum.map(fn {res, values} -> {res, do_operations(values, [:add, :multiply])} end)
    |> Enum.filter(fn {res, results} -> res in results end)
    |> Enum.map(fn {res, _results} -> res end)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      [res, values] = String.split(l, ":", trim: true)
      res = String.to_integer(res)
      values = String.split(values, " ", trim: true) |> Enum.map(fn v -> String.to_integer(v) end)
      {res, values}
    end)
    |> Enum.map(fn {res, values} -> {res, do_operations(values, [:add, :multiply, :concat])} end)
    |> Enum.filter(fn {res, results} -> res in results end)
    |> Enum.map(fn {res, _results} -> res end)
    |> Enum.sum()
  end

  defp do_operations([head | tail], operations) do
    Enum.reduce(tail, [head], fn num, acc_results ->
      Enum.flat_map(acc_results, fn acc ->
        Enum.map(operations, &apply_operation(&1, acc, num))
      end)
    end)
  end

  defp apply_operation(:add, a, b), do: a + b
  defp apply_operation(:multiply, a, b), do: a * b
  defp apply_operation(:concat, a, b), do: String.to_integer("#{a}#{b}")
end
