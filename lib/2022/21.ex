import AOC

aoc 2022, 21 do
  @moduledoc """
  Day 21: Monkey Math

  Evaluate monkey expressions (recursive computation).
  Part 1: What does 'root' monkey yell?
  Part 2: What should 'humn' yell for root's operands to be equal?
  """

  @doc """
  Part 1: Value yelled by root monkey.

  ## Examples

      iex> example = \"\"\"
      ...> root: pppw + sjmn
      ...> dbpl: 5
      ...> cczh: sllz + lgvd
      ...> zczc: 2
      ...> ptdq: humn - dvpt
      ...> dvpt: 3
      ...> lfqf: 4
      ...> humn: 5
      ...> ljgn: 2
      ...> sjmn: drzm * dbpl
      ...> sllz: 4
      ...> pppw: cczh / lfqf
      ...> lgvd: ljgn * ptdq
      ...> drzm: hmdt - zczc
      ...> hmdt: 32
      ...> \"\"\"
      iex> Y2022.D21.p1(example)
      152
  """
  def p1(input) do
    monkeys = parse(input)
    eval(monkeys, "root")
  end

  @doc """
  Part 2: Value humn should yell for equality.

  ## Examples

      iex> example = \"\"\"
      ...> root: pppw + sjmn
      ...> dbpl: 5
      ...> cczh: sllz + lgvd
      ...> zczc: 2
      ...> ptdq: humn - dvpt
      ...> dvpt: 3
      ...> lfqf: 4
      ...> humn: 5
      ...> ljgn: 2
      ...> sjmn: drzm * dbpl
      ...> sllz: 4
      ...> pppw: cczh / lfqf
      ...> lgvd: ljgn * ptdq
      ...> drzm: hmdt - zczc
      ...> hmdt: 32
      ...> \"\"\"
      iex> Y2022.D21.p2(example)
      301
  """
  def p2(input) do
    monkeys = parse(input)

    # Modify root to check equality (treat as subtraction that should equal 0)
    root = monkeys["root"]
    monkeys = Map.put(monkeys, "root", %{root | op: "-"})

    # Remove humn so it becomes a variable we need to solve for
    monkeys = Map.delete(monkeys, "humn")

    # Solve for humn starting from root = 0
    solve(monkeys, "root", 0)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Map.new()
  end

  defp parse_line(line) do
    [name, rest] = String.split(line, ": ")

    case String.split(rest) do
      [num] ->
        {name, %{value: String.to_integer(num)}}

      [left, op, right] ->
        {name, %{left: left, right: right, op: op, value: nil}}
    end
  end

  defp eval(monkeys, name) do
    case Map.get(monkeys, name) do
      nil -> nil
      %{value: v} when not is_nil(v) -> v
      %{left: left, right: right, op: op} ->
        l = eval(monkeys, left)
        r = eval(monkeys, right)

        if l == nil or r == nil do
          nil
        else
          apply_op(op, l, r)
        end
    end
  end

  defp apply_op("+", a, b), do: a + b
  defp apply_op("-", a, b), do: a - b
  defp apply_op("*", a, b), do: a * b
  defp apply_op("/", a, b), do: div(a, b)

  # Solve for humn by walking back from root
  defp solve(_monkeys, "humn", target), do: target

  defp solve(monkeys, name, target) do
    %{left: left, right: right, op: op} = monkeys[name]

    left_val = eval(monkeys, left)
    right_val = eval(monkeys, right)

    # One side has humn (returns nil), the other is a known value
    cond do
      left_val == nil ->
        # left depends on humn, solve for it
        new_target = inverse_op_left(op, target, right_val)
        solve(monkeys, left, new_target)

      right_val == nil ->
        # right depends on humn, solve for it
        new_target = inverse_op_right(op, target, left_val)
        solve(monkeys, right, new_target)
    end
  end

  # Inverse operations when solving for the LEFT operand
  # target = left OP right -> left = ?
  defp inverse_op_left("+", target, right), do: target - right
  defp inverse_op_left("-", target, right), do: target + right
  defp inverse_op_left("*", target, right), do: div(target, right)
  defp inverse_op_left("/", target, right), do: target * right

  # Inverse operations when solving for the RIGHT operand
  # target = left OP right -> right = ?
  defp inverse_op_right("+", target, left), do: target - left
  defp inverse_op_right("-", target, left), do: left - target
  defp inverse_op_right("*", target, left), do: div(target, left)
  defp inverse_op_right("/", target, left), do: div(left, target)
end
