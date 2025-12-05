import AOC

aoc 2020, 8 do
  @moduledoc """
  https://adventofcode.com/2020/day/8

  Handheld Halting - Simple VM with acc/jmp/nop, detect infinite loop.
  """

  @doc """
  Run until loop detected, return accumulator.

  ## Examples

      iex> p1("nop +0\\nacc +1\\njmp +4\\nacc +3\\njmp -3\\nacc -99\\nacc +1\\njmp -4\\nacc +6")
      5
  """
  def p1(input) do
    program = parse(input)
    {:loop, acc} = run(program)
    acc
  end

  @doc """
  Fix one instruction (jmp<->nop) to make program terminate, return accumulator.

  ## Examples

      iex> p2("nop +0\\nacc +1\\njmp +4\\nacc +3\\njmp -3\\nacc -99\\nacc +1\\njmp -4\\nacc +6")
      8
  """
  def p2(input) do
    program = parse(input)
    program_size = map_size(program)

    0..(program_size - 1)
    |> Enum.find_value(fn idx ->
      case program[idx] do
        {:jmp, n} -> try_fix(program, idx, {:nop, n})
        {:nop, n} -> try_fix(program, idx, {:jmp, n})
        _ -> nil
      end
    end)
  end

  defp try_fix(program, idx, new_instr) do
    modified = Map.put(program, idx, new_instr)
    case run(modified) do
      {:halt, acc} -> acc
      {:loop, _} -> nil
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      [op, arg] = String.split(line, " ")
      {idx, {String.to_atom(op), String.to_integer(arg)}}
    end)
    |> Map.new()
  end

  defp run(program) do
    run(program, 0, 0, MapSet.new())
  end

  defp run(program, ip, acc, visited) do
    cond do
      MapSet.member?(visited, ip) -> {:loop, acc}
      not Map.has_key?(program, ip) -> {:halt, acc}
      true ->
        visited = MapSet.put(visited, ip)
        case program[ip] do
          {:acc, n} -> run(program, ip + 1, acc + n, visited)
          {:jmp, n} -> run(program, ip + n, acc, visited)
          {:nop, _} -> run(program, ip + 1, acc, visited)
        end
    end
  end
end
