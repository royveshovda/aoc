import AOC

aoc 2022, 11 do
  def p1(input) do
    input
    |> parse_monkies()

  end

  def parse_monkies(input) do
    monkies =
      input
      |> String.split("\n\n")
      |> Enum.map(&parse_monkey/1)

    order = Enum.map(monkies, fn m -> m.id end)
    monkies = Map.new(monkies, fn m -> {m.id, m} end)

    #inspect_items(monkies[0])
    new_monkies = Enum.reduce(1..20, monkies, fn _, monkies -> round(monkies, order) end)

    new_monkies |> Enum.map(fn {_, m} -> m.inspected end) |> Enum.sort(:desc) |> Enum.take(2) |> Enum.product()
  end

  def round(monkies, []) do
    monkies
  end

  def round(monkies, [next | rest]) do
    {new_monkey, new_items} = inspect_items(monkies[next])

    monkies = Map.put(monkies, next, new_monkey)

    monkies =
      Enum.reduce(new_items, monkies, fn {receiver, value}, monkies ->
        m = monkies[receiver]
        m = %{m | items: m.items ++ [value]}
        Map.put(monkies, receiver, m)
      end)

    round(monkies, rest)
  end

  def inspect_items(monkey) do
    new_items =
      monkey.items
      |> Enum.map(fn item ->
        new_value = item |> monkey.operation.() |> div(3)
        new_holder =
          case rem(new_value, monkey.test) do
            0 -> monkey.truthy
            _ -> monkey.falsy
          end
        {new_holder, new_value}
      end)

    m = %{monkey | items: [], inspected: monkey.inspected + length(new_items)}

    {m, new_items}
  end

  def parse_monkey(input) do
    [id,items,operation,test,truthy,falsy] = String.split(input, "\n")
    id = id |> String.split(" ") |> List.last() |> String.trim() |> String.trim_trailing(":") |> String.to_integer()
    items =
      items
      |> String.split(":")
      |> List.last()
      |> String.trim()
      |> String.split(",")
      |> Enum.map(fn s -> s |> String.trim() |> String.to_integer() end)

    operation = operation |> String.trim() |> String.trim_leading("Operation: new = old ") |> String.split(" ") |> parse_operation()
    test = test |> String.trim() |> String.trim_leading("Test: divisible by ") |> String.to_integer()
    truthy = truthy |> String.trim() |> String.trim_leading("If true: throw to monkey ") |> String.to_integer()
    falsy = falsy |> String.trim() |> String.trim_leading("If false: throw to monkey ") |> String.to_integer()
    %{id: id, items: items, test: test, truthy: truthy, falsy: falsy, operation: operation, inspected: 0}
  end

  def parse_operation(["*" , "old"]) do
    fn x -> x * x end
  end

  def parse_operation(["*" , value]) do
    value = String.to_integer(value)
    fn x -> x * value end
  end

  def parse_operation(["+" , value]) do
    value = String.to_integer(value)
    fn x -> x + value end
  end

  def inspect_items_v2(monkey, divider) do
    new_items =
      monkey.items
      |> Enum.map(fn item ->
        new_value = item |> monkey.operation.() |> rem(divider)
        new_holder =
          case rem(new_value, monkey.test) do
            0 -> monkey.truthy
            _ -> monkey.falsy
          end
        {new_holder, new_value}
      end)

    m = %{monkey | items: [], inspected: monkey.inspected + length(new_items)}

    {m, new_items}
  end

  def round_v2(monkies, [], _) do
    monkies
  end

  def round_v2(monkies, [next | rest], divider) do
    {new_monkey, new_items} = inspect_items_v2(monkies[next], divider)

    monkies = Map.put(monkies, next, new_monkey)

    monkies =
      Enum.reduce(new_items, monkies, fn {receiver, value}, monkies ->
        m = monkies[receiver]
        m = %{m | items: m.items ++ [value]}
        Map.put(monkies, receiver, m)
      end)

    round_v2(monkies, rest, divider)
  end

  def p2(input) do
    monkies =
      input
      |> String.split("\n\n")
      |> Enum.map(&parse_monkey/1)

    order = Enum.map(monkies, fn m -> m.id end)
    monkies = Map.new(monkies, fn m -> {m.id, m} end)

    divider = Enum.map(monkies, fn {_, m} -> m.test end) |> Enum.product()

    new_monkies = Enum.reduce(1..10000, monkies, fn _, monkies -> round_v2(monkies, order, divider) end)
    new_monkies |> Enum.map(fn {_, m} -> m.inspected end) |> Enum.sort(:desc) |> Enum.take(2) |> Enum.product()
  end
end
