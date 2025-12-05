import AOC

aoc 2024, 24 do
  @moduledoc """
  https://adventofcode.com/2024/day/24

  Crossed Wires - logic gate simulation.
  P1: Evaluate circuit, read z-wires as binary number.
  P2: Find 4 pairs of swapped outputs in ripple-carry adder.
  """

  def p1(input) do
    {values, gates} = parse(input)
    values = evaluate(values, gates)

    values
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Enum.sort_by(fn {k, _v} -> k end, :desc)
    |> Enum.map(fn {_k, v} -> v end)
    |> Integer.undigits(2)
  end

  def p2(input) do
    {_values, gates} = parse(input)

    # Find the highest z bit
    z_max =
      gates
      |> Enum.map(fn {_a, _op, _b, out} -> out end)
      |> Enum.filter(&String.starts_with?(&1, "z"))
      |> Enum.max()

    # Find swapped wires by checking adder structure
    swapped =
      gates
      |> Enum.flat_map(fn {a, op, b, out} -> check_gate(a, op, b, out, gates, z_max) end)
      |> MapSet.new()

    swapped |> Enum.sort() |> Enum.join(",")
  end

  defp parse(input) do
    [init, gates_str] = String.split(input, "\n\n", trim: true)

    values =
      init
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [name, val] = String.split(line, ": ")
        {name, String.to_integer(val)}
      end)
      |> Map.new()

    gates =
      gates_str
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [lhs, out] = String.split(line, " -> ")
        [a, op, b] = String.split(lhs, " ")
        {a, op, b, out}
      end)

    {values, gates}
  end

  defp evaluate(values, gates) do
    ready =
      Enum.filter(gates, fn {a, _op, b, out} ->
        Map.has_key?(values, a) and Map.has_key?(values, b) and not Map.has_key?(values, out)
      end)

    if ready == [] do
      values
    else
      values =
        Enum.reduce(ready, values, fn {a, op, b, out}, vals ->
          va = Map.get(vals, a)
          vb = Map.get(vals, b)

          result =
            case op do
              "AND" -> if va == 1 and vb == 1, do: 1, else: 0
              "OR" -> if va == 1 or vb == 1, do: 1, else: 0
              "XOR" -> if va != vb, do: 1, else: 0
            end

          Map.put(vals, out, result)
        end)

      evaluate(values, gates)
    end
  end

  # Check gate structure for ripple-carry adder violations
  defp check_gate(a, op, b, out, gates, z_max) do
    cond do
      # z outputs (except last) must come from XOR
      String.starts_with?(out, "z") and out != z_max and op != "XOR" ->
        [out]

      # XOR gates must have x/y inputs or z output
      op == "XOR" and not String.starts_with?(out, "z") and
          not is_input_wire(a) and not is_input_wire(b) ->
        [out]

      # XOR with x/y inputs (not x00) must feed into another XOR
      op == "XOR" and is_input_wire(a) and is_input_wire(b) and
          not String.ends_with?(a, "00") and not feeds_into_xor(out, gates) ->
        [out]

      # AND with x/y inputs (not x00) must feed into OR
      op == "AND" and is_input_wire(a) and is_input_wire(b) and
          not String.ends_with?(a, "00") and not feeds_into_or(out, gates) ->
        [out]

      true ->
        []
    end
  end

  defp is_input_wire(w), do: String.starts_with?(w, "x") or String.starts_with?(w, "y")

  defp feeds_into_xor(wire, gates) do
    Enum.any?(gates, fn {a, op, b, _out} ->
      op == "XOR" and (a == wire or b == wire)
    end)
  end

  defp feeds_into_or(wire, gates) do
    Enum.any?(gates, fn {a, op, b, _out} ->
      op == "OR" and (a == wire or b == wire)
    end)
  end
end
