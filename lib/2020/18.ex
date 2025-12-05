import AOC

aoc 2020, 18 do
  @moduledoc """
  https://adventofcode.com/2020/day/18

  Operation Order - Expression evaluation with different precedence rules.

  ## Examples

      iex> Y2020.D18.p1("1 + 2 * 3 + 4 * 5 + 6")
      71

      iex> Y2020.D18.p1("1 + (2 * 3) + (4 * (5 + 6))")
      51

      iex> Y2020.D18.p1("2 * 3 + (4 * 5)")
      26

      iex> Y2020.D18.p1("5 + (8 * 3 + 9 + 3 * 4 * 3)")
      437

      iex> Y2020.D18.p1("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
      12240

      iex> Y2020.D18.p1("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
      13632

      iex> Y2020.D18.p2("1 + 2 * 3 + 4 * 5 + 6")
      231

      iex> Y2020.D18.p2("1 + (2 * 3) + (4 * (5 + 6))")
      51

      iex> Y2020.D18.p2("2 * 3 + (4 * 5)")
      46

      iex> Y2020.D18.p2("5 + (8 * 3 + 9 + 3 * 4 * 3)")
      1445

      iex> Y2020.D18.p2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
      669060

      iex> Y2020.D18.p2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
      23340
  """

  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&eval_left_to_right/1)
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&eval_add_before_mul/1)
    |> Enum.sum()
  end

  # Part 1: Left-to-right evaluation (+ and * same precedence)
  defp eval_left_to_right(expr) do
    tokens = tokenize(expr)
    {result, []} = parse_expr_ltr(tokens)
    result
  end

  defp parse_expr_ltr(tokens) do
    {left, rest} = parse_atom_ltr(tokens)
    parse_ops_ltr(left, rest)
  end

  defp parse_ops_ltr(acc, []), do: {acc, []}
  defp parse_ops_ltr(acc, [")" | _] = rest), do: {acc, rest}

  defp parse_ops_ltr(acc, ["+" | rest]) do
    {right, rest2} = parse_atom_ltr(rest)
    parse_ops_ltr(acc + right, rest2)
  end

  defp parse_ops_ltr(acc, ["*" | rest]) do
    {right, rest2} = parse_atom_ltr(rest)
    parse_ops_ltr(acc * right, rest2)
  end

  defp parse_atom_ltr(["(" | rest]) do
    {result, [")" | rest2]} = parse_expr_ltr(rest)
    {result, rest2}
  end

  defp parse_atom_ltr([num | rest]) when is_integer(num), do: {num, rest}

  # Part 2: Addition before multiplication
  defp eval_add_before_mul(expr) do
    tokens = tokenize(expr)
    {result, []} = parse_mul(tokens)
    result
  end

  # Lower precedence: multiplication
  defp parse_mul(tokens) do
    {left, rest} = parse_add(tokens)
    parse_mul_ops(left, rest)
  end

  defp parse_mul_ops(acc, []), do: {acc, []}
  defp parse_mul_ops(acc, [")" | _] = rest), do: {acc, rest}

  defp parse_mul_ops(acc, ["*" | rest]) do
    {right, rest2} = parse_add(rest)
    parse_mul_ops(acc * right, rest2)
  end

  defp parse_mul_ops(acc, rest), do: {acc, rest}

  # Higher precedence: addition
  defp parse_add(tokens) do
    {left, rest} = parse_atom_p2(tokens)
    parse_add_ops(left, rest)
  end

  defp parse_add_ops(acc, []), do: {acc, []}
  defp parse_add_ops(acc, [")" | _] = rest), do: {acc, rest}
  defp parse_add_ops(acc, ["*" | _] = rest), do: {acc, rest}

  defp parse_add_ops(acc, ["+" | rest]) do
    {right, rest2} = parse_atom_p2(rest)
    parse_add_ops(acc + right, rest2)
  end

  defp parse_atom_p2(["(" | rest]) do
    {result, [")" | rest2]} = parse_mul(rest)
    {result, rest2}
  end

  defp parse_atom_p2([num | rest]) when is_integer(num), do: {num, rest}

  # Tokenizer
  defp tokenize(expr) do
    expr
    |> String.replace("(", "( ")
    |> String.replace(")", " )")
    |> String.split(" ", trim: true)
    |> Enum.map(fn
      "+" -> "+"
      "*" -> "*"
      "(" -> "("
      ")" -> ")"
      n -> String.to_integer(n)
    end)
  end
end
