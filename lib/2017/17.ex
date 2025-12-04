import AOC

aoc 2017, 17 do
  @moduledoc """
  https://adventofcode.com/2017/day/17
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    steps = String.trim(input) |> String.to_integer()
    {buffer, _pos} = Enum.reduce(1..2017, {[0], 0}, fn val, {buf, pos} ->
      new_pos = rem(pos + steps, length(buf)) + 1
      {List.insert_at(buf, new_pos, val), new_pos}
    end)
    idx = Enum.find_index(buffer, &(&1 == 2017))
    Enum.at(buffer, rem(idx + 1, length(buffer)))
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    steps = String.trim(input) |> String.to_integer()
    simulate_fast(steps, 50_000_000)
  end

  defp simulate_fast(steps, iterations) do
    Enum.reduce(1..iterations, {0, 0}, fn val, {pos, after_zero} ->
      buffer_len = val
      new_pos = rem(pos + steps, buffer_len) + 1
      new_after_zero = if new_pos == 1, do: val, else: after_zero
      {new_pos, new_after_zero}
    end)
    |> elem(1)
  end
end
