import AOC

aoc 2022, 20 do
  @moduledoc """
  Day 20: Grove Positioning System

  Mix numbers in circular list by moving each number.
  Part 1: Mix once, sum of 1000th, 2000th, 3000th after 0.
  Part 2: Multiply by decryption key, mix 10 times.
  """

  @doc """
  Part 1: Sum of grove coordinates after mixing once.

  ## Examples

      iex> example = \"\"\"
      ...> 1
      ...> 2
      ...> -3
      ...> 3
      ...> -2
      ...> 0
      ...> 4
      ...> \"\"\"
      iex> Y2022.D20.p1(example)
      3
  """
  def p1(input) do
    numbers =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()

    mixed = mix(numbers, numbers)
    grove_coordinates(mixed)
  end

  @doc """
  Part 2: Grove coordinates with decryption key, 10 mixes.

  ## Examples

      iex> example = \"\"\"
      ...> 1
      ...> 2
      ...> -3
      ...> 3
      ...> -2
      ...> 0
      ...> 4
      ...> \"\"\"
      iex> Y2022.D20.p2(example)
      1623178306
  """
  def p2(input) do
    decryption_key = 811_589_153

    numbers =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&(&1 * decryption_key))
      |> Enum.with_index()

    mixed = Enum.reduce(1..10, numbers, fn _, acc -> mix(numbers, acc) end)
    grove_coordinates(mixed)
  end

  defp mix(original, current) do
    Enum.reduce(original, current, fn {value, orig_idx} = item, acc ->
      current_idx = Enum.find_index(acc, fn x -> x == item end)
      list_without = List.delete_at(acc, current_idx)
      len = length(list_without)

      # Calculate new position with proper modulo for circular list
      new_idx = Integer.mod(current_idx + value, len)
      new_idx = if new_idx == 0 and value != 0, do: len, else: new_idx

      List.insert_at(list_without, new_idx, {value, orig_idx})
    end)
  end

  defp grove_coordinates(mixed) do
    values = Enum.map(mixed, fn {v, _} -> v end)
    len = length(values)
    zero_idx = Enum.find_index(values, &(&1 == 0))

    [1000, 2000, 3000]
    |> Enum.map(fn offset -> Enum.at(values, rem(zero_idx + offset, len)) end)
    |> Enum.sum()
  end
end
