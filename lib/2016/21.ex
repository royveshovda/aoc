import AOC

aoc 2016, 21 do
  @moduledoc """
  https://adventofcode.com/2016/day/21
  """

  def p1(input) do
    operations = parse(input)
    "abcdefgh"
    |> String.graphemes()
    |> apply_operations(operations)
    |> Enum.join()
  end

  def p2(input) do
    operations = parse(input) |> Enum.reverse()
    "fbgdceah"
    |> String.graphemes()
    |> apply_operations(operations, :reverse)
    |> Enum.join()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    cond do
      String.starts_with?(line, "swap position") ->
        [_, _, x, _, _, y] = String.split(line)
        {:swap_pos, String.to_integer(x), String.to_integer(y)}

      String.starts_with?(line, "swap letter") ->
        [_, _, a, _, _, b] = String.split(line)
        {:swap_letter, a, b}

      String.starts_with?(line, "rotate left") ->
        parts = String.split(line)
        steps = parts |> Enum.at(2) |> String.to_integer()
        {:rotate, -steps}

      String.starts_with?(line, "rotate right") ->
        parts = String.split(line)
        steps = parts |> Enum.at(2) |> String.to_integer()
        {:rotate, steps}

      String.starts_with?(line, "rotate based") ->
        parts = String.split(line)
        {:rotate_based, List.last(parts)}

      String.starts_with?(line, "reverse") ->
        parts = String.split(line)
        x = parts |> Enum.at(2) |> String.to_integer()
        y = parts |> Enum.at(4) |> String.to_integer()
        {:reverse, x, y}

      String.starts_with?(line, "move") ->
        parts = String.split(line)
        x = parts |> Enum.at(2) |> String.to_integer()
        y = parts |> Enum.at(5) |> String.to_integer()
        {:move, x, y}
    end
  end

  defp apply_operations(chars, operations, mode \\ :forward) do
    Enum.reduce(operations, chars, fn op, acc ->
      apply_operation(acc, op, mode)
    end)
  end

  defp apply_operation(chars, {:swap_pos, x, y}, _mode) do
    a = Enum.at(chars, x)
    b = Enum.at(chars, y)
    chars
    |> List.replace_at(x, b)
    |> List.replace_at(y, a)
  end

  defp apply_operation(chars, {:swap_letter, a, b}, _mode) do
    Enum.map(chars, fn
      ^a -> b
      ^b -> a
      c -> c
    end)
  end

  defp apply_operation(chars, {:rotate, steps}, :forward) do
    rotate_list(chars, steps)
  end

  defp apply_operation(chars, {:rotate, steps}, :reverse) do
    rotate_list(chars, -steps)
  end

  defp apply_operation(chars, {:rotate_based, letter}, :forward) do
    index = Enum.find_index(chars, &(&1 == letter))
    steps = 1 + index + if index >= 4, do: 1, else: 0
    rotate_list(chars, steps)
  end

  defp apply_operation(chars, {:rotate_based, letter}, :reverse) do
    # For reverse, try all positions to find which one would result in current state
    len = length(chars)
    target_index = Enum.find_index(chars, &(&1 == letter))

    original_index =
      0..(len - 1)
      |> Enum.find(fn i ->
        steps = 1 + i + if i >= 4, do: 1, else: 0
        rem(i + steps, len) == target_index
      end)

    steps = 1 + original_index + if original_index >= 4, do: 1, else: 0
    rotate_list(chars, -steps)
  end

  defp apply_operation(chars, {:reverse, x, y}, _mode) do
    before = Enum.slice(chars, 0, x)
    middle = Enum.slice(chars, x, y - x + 1) |> Enum.reverse()
    after_part = Enum.slice(chars, (y + 1)..-1//1)
    before ++ middle ++ after_part
  end

  defp apply_operation(chars, {:move, x, y}, :forward) do
    char = Enum.at(chars, x)
    chars
    |> List.delete_at(x)
    |> List.insert_at(y, char)
  end

  defp apply_operation(chars, {:move, x, y}, :reverse) do
    # Reverse move: move from y to x
    char = Enum.at(chars, y)
    chars
    |> List.delete_at(y)
    |> List.insert_at(x, char)
  end

  defp rotate_list(list, steps) do
    len = length(list)
    steps = rem(steps, len)
    steps = if steps < 0, do: steps + len, else: steps

    {left, right} = Enum.split(list, len - steps)
    right ++ left
  end
end
