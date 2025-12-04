import AOC
import Bitwise

aoc 2015, 7 do
  @moduledoc """
  https://adventofcode.com/2015/day/7

  Day 7: Some Assembly Required
  Simulate a circuit with bitwise logic gates. 16-bit signals (0-65535).
  """

  @doc """
  Part 1: What signal is ultimately provided to wire 'a'?

  Operations:
  - Direct assignment: "123 -> x" or "x -> y"
  - AND: "x AND y -> z"
  - OR: "x OR y -> z"
  - LSHIFT: "x LSHIFT 2 -> y"
  - RSHIFT: "x RSHIFT 2 -> y"
  - NOT: "NOT x -> y"
  """
  def p1(input) do
    circuit = parse_circuit(input)
    {value, _cache} = evaluate(circuit, "a", %{})
    value
  end

  @doc """
  Part 2: Override wire 'b' with the signal from wire 'a' in part 1,
  then calculate the new signal on wire 'a'.
  """
  def p2(input) do
    circuit = parse_circuit(input)
    {a_value, _cache} = evaluate(circuit, "a", %{})

    # Override wire b with a's value
    circuit_with_override = Map.put(circuit, "b", {:value, a_value})
    {new_value, _cache} = evaluate(circuit_with_override, "a", %{})
    new_value
  end

  defp parse_circuit(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
    |> Map.new()
  end

  defp parse_instruction(line) do
    [left, wire] = String.split(line, " -> ")
    {wire, parse_operation(left)}
  end

  defp parse_operation(op) do
    cond do
      # NOT operation
      String.starts_with?(op, "NOT ") ->
        wire = String.trim_leading(op, "NOT ")
        {:not, wire}

      # Binary operations (AND, OR, LSHIFT, RSHIFT)
      String.contains?(op, " AND ") ->
        [a, b] = String.split(op, " AND ")
        {:and, a, b}

      String.contains?(op, " OR ") ->
        [a, b] = String.split(op, " OR ")
        {:or, a, b}

      String.contains?(op, " LSHIFT ") ->
        [wire, amount] = String.split(op, " LSHIFT ")
        {:lshift, wire, String.to_integer(amount)}

      String.contains?(op, " RSHIFT ") ->
        [wire, amount] = String.split(op, " RSHIFT ")
        {:rshift, wire, String.to_integer(amount)}

      # Direct value or wire reference
      true ->
        case Integer.parse(op) do
          {num, ""} -> {:value, num}
          _ -> {:wire, op}
        end
    end
  end

  # Evaluate a wire's value with memoization
  defp evaluate(circuit, wire, cache) do
    if Map.has_key?(cache, wire) do
      {cache[wire], cache}
    else
      operation = Map.get(circuit, wire)
      {value, new_cache} = eval_operation(circuit, operation, cache)
      # Ensure 16-bit value
      value = value &&& 0xFFFF
      {value, Map.put(new_cache, wire, value)}
    end
  end

  defp eval_operation(_circuit, {:value, num}, cache), do: {num, cache}

  defp eval_operation(circuit, {:wire, wire}, cache) do
    evaluate(circuit, wire, cache)
  end

  defp eval_operation(circuit, {:not, wire}, cache) do
    {val, new_cache} = get_value(circuit, wire, cache)
    {~~~val, new_cache}
  end

  defp eval_operation(circuit, {:and, a, b}, cache) do
    {val_a, cache1} = get_value(circuit, a, cache)
    {val_b, cache2} = get_value(circuit, b, cache1)
    {val_a &&& val_b, cache2}
  end

  defp eval_operation(circuit, {:or, a, b}, cache) do
    {val_a, cache1} = get_value(circuit, a, cache)
    {val_b, cache2} = get_value(circuit, b, cache1)
    {val_a ||| val_b, cache2}
  end

  defp eval_operation(circuit, {:lshift, wire, amount}, cache) do
    {val, new_cache} = get_value(circuit, wire, cache)
    {val <<< amount, new_cache}
  end

  defp eval_operation(circuit, {:rshift, wire, amount}, cache) do
    {val, new_cache} = get_value(circuit, wire, cache)
    {val >>> amount, new_cache}
  end

  # Get value from either a literal number or a wire
  defp get_value(circuit, operand, cache) do
    case Integer.parse(operand) do
      {num, ""} -> {num, cache}
      _ -> evaluate(circuit, operand, cache)
    end
  end
end
