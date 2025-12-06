import AOC

aoc 2022, 11 do
  @moduledoc """
  Day 11: Monkey in the Middle

  Monkeys pass items based on operations and divisibility tests.
  Part 1: 20 rounds with worry / 3.
  Part 2: 10000 rounds without division (use modular arithmetic).
  """

  @doc """
  Part 1: Product of top 2 inspection counts after 20 rounds.
  """
  def p1(input) do
    monkeys = parse(input)
    run_rounds(monkeys, 20, &div(&1, 3))
  end

  @doc """
  Part 2: Product of top 2 inspection counts after 10000 rounds.
  """
  def p2(input) do
    monkeys = parse(input)
    # Use LCM of all divisors to keep numbers manageable
    lcm = monkeys |> Enum.map(fn m -> m.test end) |> Enum.product()
    run_rounds(monkeys, 10000, &rem(&1, lcm))
  end

  defp run_rounds(monkeys, rounds, worry_reduce) do
    monkeys_map = monkeys |> Enum.with_index() |> Map.new(fn {m, i} -> {i, m} end)

    final_monkeys =
      Enum.reduce(1..rounds, monkeys_map, fn _round, monkeys ->
        do_round(monkeys, worry_reduce)
      end)

    final_monkeys
    |> Map.values()
    |> Enum.map(& &1.inspections)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp do_round(monkeys, worry_reduce) do
    Enum.reduce(0..(map_size(monkeys) - 1), monkeys, fn idx, monkeys ->
      monkey = monkeys[idx]

      Enum.reduce(monkey.items, monkeys, fn item, monkeys ->
        new_worry = apply_op(monkey.op, item) |> worry_reduce.()
        target = if rem(new_worry, monkey.test) == 0, do: monkey.if_true, else: monkey.if_false

        monkeys
        |> update_in([target, :items], &(&1 ++ [new_worry]))
        |> update_in([idx, :inspections], &(&1 + 1))
      end)
      |> put_in([idx, :items], [])
    end)
  end

  defp apply_op({:add, :old}, val), do: val + val
  defp apply_op({:add, n}, val), do: val + n
  defp apply_op({:mul, :old}, val), do: val * val
  defp apply_op({:mul, n}, val), do: val * n

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_monkey/1)
  end

  defp parse_monkey(block) do
    lines = String.split(block, "\n", trim: true)

    items =
      lines
      |> Enum.at(1)
      |> then(&Regex.scan(~r/\d+/, &1))
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    op = parse_operation(Enum.at(lines, 2))

    test =
      lines
      |> Enum.at(3)
      |> then(&Regex.run(~r/\d+/, &1))
      |> hd()
      |> String.to_integer()

    if_true =
      lines
      |> Enum.at(4)
      |> then(&Regex.run(~r/\d+/, &1))
      |> hd()
      |> String.to_integer()

    if_false =
      lines
      |> Enum.at(5)
      |> then(&Regex.run(~r/\d+/, &1))
      |> hd()
      |> String.to_integer()

    %{
      items: items,
      op: op,
      test: test,
      if_true: if_true,
      if_false: if_false,
      inspections: 0
    }
  end

  defp parse_operation(line) do
    cond do
      String.contains?(line, "old * old") ->
        {:mul, :old}

      String.contains?(line, "old + old") ->
        {:add, :old}

      String.contains?(line, "*") ->
        [n] = Regex.run(~r/\* (\d+)/, line, capture: :all_but_first)
        {:mul, String.to_integer(n)}

      String.contains?(line, "+") ->
        [n] = Regex.run(~r/\+ (\d+)/, line, capture: :all_but_first)
        {:add, String.to_integer(n)}
    end
  end
end
