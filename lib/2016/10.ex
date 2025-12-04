import AOC

aoc 2016, 10 do
  @moduledoc """
  https://adventofcode.com/2016/day/10
  Day 10: Balance Bots - bot simulation
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    {instructions, values} = parse_input(input)
    {bot, _, _} = simulate(instructions, values, [17, 61])  # Sorted order
    bot
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    {instructions, values} = parse_input(input)
    {_, outputs, _} = simulate(instructions, values, nil)
    outputs[0] * outputs[1] * outputs[2]
  end

  defp parse_input(input) do
    lines = input |> String.trim() |> String.split("\n", trim: true)

    {instructions, values} = Enum.split_with(lines, &String.starts_with?(&1, "bot"))

    instr_map =
      instructions
      |> Enum.map(&parse_instruction/1)
      |> Map.new()

    value_list = Enum.map(values, &parse_value/1)

    {instr_map, value_list}
  end

  defp parse_instruction(line) do
    ~r/bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/
    |> Regex.run(line)
    |> case do
      [_, bot, low_type, low_num, high_type, high_num] ->
        {String.to_integer(bot), {
          {low_type, String.to_integer(low_num)},
          {high_type, String.to_integer(high_num)}
        }}
    end
  end

  defp parse_value(line) do
    ~r/value (\d+) goes to bot (\d+)/
    |> Regex.run(line)
    |> case do
      [_, value, bot] -> {String.to_integer(value), String.to_integer(bot)}
    end
  end

  defp simulate(instructions, values, target) do
    bots = Enum.reduce(values, %{}, fn {val, bot}, acc ->
      Map.update(acc, bot, [val], &[val | &1])
    end)

    execute_bots(instructions, bots, %{}, target, nil)
  end

  defp execute_bots(instructions, bots, outputs, target, found_bot) do
    case Enum.find(bots, fn {_, vals} -> length(vals) == 2 end) do
      nil -> {found_bot, outputs, bots}
      {bot_num, [a, b]} ->
        [low, high] = Enum.sort([a, b])

        new_found = cond do
          target && [low, high] == target -> bot_num
          found_bot -> found_bot
          true -> nil
        end

        {{low_type, low_dest}, {high_type, high_dest}} = instructions[bot_num]

        new_bots = Map.delete(bots, bot_num)
        {new_bots, new_outputs} = give_value(new_bots, low_type, low_dest, low, outputs)
        {new_bots, new_outputs} = give_value(new_bots, high_type, high_dest, high, new_outputs)

        execute_bots(instructions, new_bots, new_outputs, target, new_found)
    end
  end

  defp give_value(bots, "bot", num, value, outputs) do
    {Map.update(bots, num, [value], &[value | &1]), outputs}
  end

  defp give_value(bots, "output", num, value, outputs) do
    {bots, Map.put(outputs, num, value)}
  end
end
