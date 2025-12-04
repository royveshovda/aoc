import AOC

aoc 2017, 16 do
  @moduledoc """
  https://adventofcode.com/2017/day/16
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    moves = parse(input)
    programs = Enum.to_list(?a..?p) |> List.to_string()
    dance(programs, moves) |> List.to_string()
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    moves = parse(input)
    programs = Enum.to_list(?a..?p) |> List.to_string()
    find_cycle(programs, moves, 1_000_000_000)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_move/1)
  end

  defp parse_move("s" <> n), do: {:spin, String.to_integer(n)}
  defp parse_move("x" <> rest) do
    [a, b] = String.split(rest, "/")
    {:exchange, String.to_integer(a), String.to_integer(b)}
  end
  defp parse_move("p" <> rest) do
    [a, b] = String.split(rest, "/")
    {:partner, a, b}
  end

  defp dance(programs, moves) when is_binary(programs) do
    programs
    |> String.graphemes()
    |> dance(moves)
  end
  defp dance(programs, moves) when is_list(programs) do
    Enum.reduce(moves, programs, &apply_move/2)
  end

  defp apply_move({:spin, n}, programs) do
    {rest, front} = Enum.split(programs, -n)
    front ++ rest
  end
  defp apply_move({:exchange, a, b}, programs) do
    va = Enum.at(programs, a)
    vb = Enum.at(programs, b)
    programs
    |> List.replace_at(a, vb)
    |> List.replace_at(b, va)
  end
  defp apply_move({:partner, a, b}, programs) do
    ia = Enum.find_index(programs, &(&1 == a))
    ib = Enum.find_index(programs, &(&1 == b))
    apply_move({:exchange, ia, ib}, programs)
  end

  defp find_cycle(programs, moves, target) do
    iterate(programs, moves, 0, target, %{programs => 0})
  end

  defp iterate(programs, _moves, step, target, _seen) when step == target do
    if is_list(programs), do: List.to_string(programs), else: programs
  end
  defp iterate(programs, moves, step, target, seen) do
    next = dance(programs, moves)

    case Map.get(seen, next) do
      nil ->
        iterate(next, moves, step + 1, target, Map.put(seen, next, step + 1))

      cycle_start ->
        cycle_length = step + 1 - cycle_start
        remaining = target - step - 1
        skip_cycles = rem(remaining, cycle_length)
        result = Enum.reduce(1..skip_cycles, next, fn _, p -> dance(p, moves) end)
        if is_list(result), do: List.to_string(result), else: result
    end
  end
end
