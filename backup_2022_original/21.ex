import AOC

aoc 2022, 21 do
  def p1(input) do
    monkeys =
      input
      |> String.split("\n")
      |> Enum.map(&parse_line(&1))
      |> Map.new()

    eval(monkeys, "root")
  end

  def parse_line(line) do
    [key, value] = String.split(line, ":")
    values = value |> String.trim() |> String.split(" ")

    {
      key,
      parse_values(values)
    }
  end

  def parse_values([value]) do
    v = String.to_integer(value)
    %{
      value: v
    }
  end

  def parse_values([input1, operator, input2]) do
    %{
      input1: input1,
      input2: input2,
      operator: operator,
      value: nil
    }
  end

  def p2(input) do
    monkeys =
      input
      |> String.split("\n")
      |> Enum.map(&parse_line(&1))
      |> Map.new()

    root = monkeys["root"]
    monkeys =
      monkeys
      |> Map.put("root", %{root | operator: "-"})
      |> Map.delete("humn")

    findval(monkeys, "root", 0)
  end

  def findval(_monkeys, "humn", target) do
    target
  end

  def findval(monkeys, me, target) do
    me = monkeys[me]

    d1 = eval(monkeys, me.input1)
    d2 = eval(monkeys, me.input2)

    case me.operator do
      "+" ->
        if d1 == nil do
          findval(monkeys, me.input1, target - d2)
        else
          findval(monkeys, me.input2, target - d1)
        end

      "-" ->
        if d1 == nil do
          findval(monkeys, me.input1, target + d2)
        else
          findval(monkeys, me.input2, d1 - target)
        end

      "*" ->
        if d1 == nil do
          findval(monkeys, me.input1, div(target, d2))
        else
          findval(monkeys, me.input2, div(target, d1))
        end

      "/" ->
        if d1 == nil do
          findval(monkeys, me.input1, target * d2)
        else
          findval(monkeys, me.input2, div(d1, target))
        end
    end
  end

  def eval(monkeys, me) do
    me = monkeys[me]

    cond do
      is_nil(me) ->
        nil

      me.value != nil ->
        me.value

      true ->
        d1 = eval(monkeys, me.input1)
        d2 = eval(monkeys, me.input2)

        if d1 == nil or d2 == nil do
          nil
        else
          case me.operator do
            "+" -> d1 + d2
            "-" -> d1 - d2
            "*" -> d1 * d2
            "/" -> div(d1, d2)
          end
        end
    end
  end
end
