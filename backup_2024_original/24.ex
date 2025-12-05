import AOC
import Bitwise

aoc 2024, 24 do
  @moduledoc """
  https://adventofcode.com/2024/day/24
  Source: https://github.com/liamcmitchell/advent-of-code/blob/4abc416e21ee88001295d4452b7a62fe25c90856/2024/24/1.exs
  """

  def p1(input) do
    input |> parse() |> calculate()
  end

  def p2(input) do
    map = input |> parse()

    map
    |> Map.keys()
    |> Enum.filter(fn wire -> wire |> String.starts_with?("z") end)
    |> Enum.sort()
    |> Enum.reduce({[], map}, fn wire, {swapped, map} ->
      bit = wire |> String.slice(1, 2) |> String.to_integer()
      expected = adder(bit)
      actual = resolve_tree(map, wire)

      if expected != actual do
        wires =
          map
          |> Map.keys()
          |> Enum.map(fn wire -> {resolve_tree(map, wire), wire} end)
          |> Map.new()

        case find_swap(wires, expected, actual) do
          {a, b} ->
            map =
              map
              |> Map.put(a, Map.get(map, b))
              |> Map.put(b, Map.get(map, a))

            {[a, b | swapped], map}

          nil ->
            {swapped, map}
        end
      else
        {swapped, map}
      end
    end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.join(",")
  end


  def parse(input) do
    [initial, gates] = input |> String.split("\n\n")

    initial =
      initial
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [wire, value] = line |> String.split(": ")
        {wire, String.to_integer(value)}
      end)

    gates =
      gates
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [in1, gate, in2, _, wire] = line |> String.split()
        {wire, {gate, in1, in2}}
      end)

    initial |> Enum.concat(gates) |> Map.new()
  end

  def resolve(_map, value) when is_integer(value), do: value
  def resolve(map, value) when is_bitstring(value), do: resolve(map, Map.get(map, value, 0))
  def resolve(map, {"AND", in1, in2}), do: band(resolve(map, in1), resolve(map, in2))
  def resolve(map, {"OR", in1, in2}), do: bor(resolve(map, in1), resolve(map, in2))
  def resolve(map, {"XOR", in1, in2}), do: bxor(resolve(map, in1), resolve(map, in2))

  def resolve_tree(map, wire) do
    case map do
      %{^wire => {gate, a, b}} ->
        op(gate, resolve_tree(map, a), resolve_tree(map, b))
      _ ->
        wire
    end
  end

  def adder(0), do: op("XOR", x(0), y(0))

  def adder(bit) do
    op("XOR", op("XOR", x(bit), y(bit)), remainder(bit - 1))
  end

  def remainder(0), do: op("AND", x(0), y(0))

  def remainder(bit),
    do:
      op(
        "OR",
        op("AND", x(bit), y(bit)),
        op(
          "AND",
          op("XOR", x(bit), y(bit)),
          remainder(bit - 1)
        )
      )

  def pad(bit), do: bit |> Integer.to_string() |> String.pad_leading(2, "0")
  def x(bit), do: "x#{pad(bit)}"
  def y(bit), do: "y#{pad(bit)}"

  def op(gate, a, b), do: {gate, MapSet.new([a, b])}

  def calculate(map) do
    map
    |> Enum.filter(fn {wire, _} -> wire |> String.starts_with?("z") end)
    |> Enum.map(fn {wire, value} ->
      bit = wire |> String.slice(1, 2) |> String.to_integer()
      value = resolve(map, value)
      bsl(value, bit)
    end)
    |> Enum.sum()
  end

  def find_swap(wires, expected, actual) do
    case wires do
      %{^expected => a} ->
        {a, Map.get(wires, actual)}

      _ ->
        [e1, e2] = expected |> elem(1) |> MapSet.to_list()
        [a1, a2] = actual |> elem(1) |> MapSet.to_list()

        cond do
          e1 == a1 ->
            find_swap(wires, e2, a2)

          e1 == a2 ->
            find_swap(wires, e2, a1)

          e2 == a1 ->
            find_swap(wires, e1, a2)

          e2 == a2 ->
            find_swap(wires, e1, a1)

          true ->
            nil
        end
    end
  end
end
