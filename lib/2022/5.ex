import AOC

aoc 2022, 5 do
  @moduledoc """
  Day 5: Supply Stacks

  Move crates between stacks.
  Part 1: CrateMover 9000 - moves one at a time.
  Part 2: CrateMover 9001 - moves multiple at once (preserve order).
  """

  @doc """
  Part 1: Return top crates after moves (CrateMover 9000).

  ## Examples

      iex> example = "    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3 \\n\\nmove 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2"
      iex> p1(example)
      "CMZ"
  """
  def p1(input) do
    {stacks, moves} = parse(input)

    stacks
    |> apply_moves(moves, &move_one_at_a_time/4)
    |> get_tops()
  end

  @doc """
  Part 2: Return top crates after moves (CrateMover 9001).

  ## Examples

      iex> example = "    [D]    \\n[N] [C]    \\n[Z] [M] [P]\\n 1   2   3 \\n\\nmove 1 from 2 to 1\\nmove 3 from 1 to 3\\nmove 2 from 2 to 1\\nmove 1 from 1 to 2"
      iex> p2(example)
      "MCD"
  """
  def p2(input) do
    {stacks, moves} = parse(input)

    stacks
    |> apply_moves(moves, &move_multiple_at_once/4)
    |> get_tops()
  end

  defp parse(input) do
    [stack_part, moves_part] = String.split(input, "\n\n")

    stacks = parse_stacks(stack_part)
    moves = parse_moves(moves_part)

    {stacks, moves}
  end

  defp parse_stacks(stack_part) do
    lines = String.split(stack_part, "\n")
    # Last line is the stack numbers, ignore it
    crate_lines = Enum.drop(lines, -1)

    # Each stack position is at 4n+1 (0-indexed: 1, 5, 9, ...)
    # Find max width to determine number of stacks
    max_width = crate_lines |> Enum.map(&String.length/1) |> Enum.max(fn -> 0 end)
    num_stacks = div(max_width + 1, 4)

    # Build stacks from top to bottom
    Enum.reduce(crate_lines, Map.new(1..num_stacks, fn i -> {i, []} end), fn line, stacks ->
      chars = String.to_charlist(line)

      Enum.reduce(1..num_stacks, stacks, fn stack_num, acc ->
        pos = (stack_num - 1) * 4 + 1

        case Enum.at(chars, pos) do
          nil -> acc
          ?\s -> acc
          char -> Map.update!(acc, stack_num, &(&1 ++ [<<char>>]))
        end
      end)
    end)
  end

  defp parse_moves(moves_part) do
    moves_part
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [count, from, to] =
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      {count, from, to}
    end)
  end

  defp apply_moves(stacks, moves, move_fn) do
    Enum.reduce(moves, stacks, fn {count, from, to}, acc ->
      move_fn.(acc, count, from, to)
    end)
  end

  # CrateMover 9000: moves one crate at a time (reverses order)
  defp move_one_at_a_time(stacks, count, from, to) do
    {moved, remaining} = Enum.split(stacks[from], count)
    stacks
    |> Map.put(from, remaining)
    |> Map.update!(to, fn stack -> Enum.reverse(moved) ++ stack end)
  end

  # CrateMover 9001: moves multiple crates at once (preserves order)
  defp move_multiple_at_once(stacks, count, from, to) do
    {moved, remaining} = Enum.split(stacks[from], count)
    stacks
    |> Map.put(from, remaining)
    |> Map.update!(to, fn stack -> moved ++ stack end)
  end

  defp get_tops(stacks) do
    1..map_size(stacks)
    |> Enum.map(fn i -> List.first(stacks[i], "") end)
    |> Enum.join()
  end
end
