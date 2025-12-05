import AOC
import Bitwise

aoc 2020, 14 do
  @moduledoc """
  https://adventofcode.com/2020/day/14

  Docking Data - Bitmask operations on values and addresses.

  ## Examples

      iex> example = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X\\nmem[8] = 11\\nmem[7] = 101\\nmem[8] = 0"
      iex> Y2020.D14.p1(example)
      165

      iex> example = "mask = 000000000000000000000000000000X1001X\\nmem[42] = 100\\nmask = 00000000000000000000000000000000X0XX\\nmem[26] = 1"
      iex> Y2020.D14.p2(example)
      208
  """

  def p1(input) do
    input
    |> parse()
    |> run_v1()
    |> Map.values()
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> parse()
    |> run_v2()
    |> Map.values()
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line("mask = " <> mask), do: {:mask, mask}

  defp parse_line(line) do
    [addr, val] = Regex.run(~r/mem\[(\d+)\] = (\d+)/, line, capture: :all_but_first)
    {:mem, String.to_integer(addr), String.to_integer(val)}
  end

  # Part 1: Apply mask to values
  defp run_v1(instructions) do
    {_mask, memory} =
      Enum.reduce(instructions, {nil, %{}}, fn
        {:mask, mask}, {_old_mask, memory} ->
          {mask, memory}

        {:mem, addr, val}, {mask, memory} ->
          masked_val = apply_mask_v1(val, mask)
          {mask, Map.put(memory, addr, masked_val)}
      end)

    memory
  end

  defp apply_mask_v1(val, mask) do
    mask
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(val, fn
      {"X", _bit}, acc -> acc
      {"1", bit}, acc -> acc ||| (1 <<< bit)
      {"0", bit}, acc -> acc &&& ~~~(1 <<< bit)
    end)
  end

  # Part 2: Apply mask to addresses (floating bits)
  defp run_v2(instructions) do
    {_mask, memory} =
      Enum.reduce(instructions, {nil, %{}}, fn
        {:mask, mask}, {_old_mask, memory} ->
          {mask, memory}

        {:mem, addr, val}, {mask, memory} ->
          addrs = apply_mask_v2(addr, mask)
          new_memory = Enum.reduce(addrs, memory, &Map.put(&2, &1, val))
          {mask, new_memory}
      end)

    memory
  end

  defp apply_mask_v2(addr, mask) do
    mask
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce([addr], fn
      {"0", _bit}, addrs ->
        # Keep unchanged
        addrs

      {"1", bit}, addrs ->
        # Set to 1
        Enum.map(addrs, &(&1 ||| (1 <<< bit)))

      {"X", bit}, addrs ->
        # Floating - generate both 0 and 1
        Enum.flat_map(addrs, fn a ->
          [a &&& ~~~(1 <<< bit), a ||| (1 <<< bit)]
        end)
    end)
  end
end
