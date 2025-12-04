import AOC

aoc 2017, 8 do
  @moduledoc """
  https://adventofcode.com/2017/day/8
  """

  def p1(input) do
    {registers, _} = execute(input)
    registers |> Map.values() |> Enum.max()
  end

  def p2(input) do
    {_, max_ever} = execute(input)
    max_ever
  end

  defp execute(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, 0}, fn line, {registers, max_ever} ->
      [reg, op, amount, "if", cond_reg, cond_op, cond_val] = String.split(line)

      amount = String.to_integer(amount)
      cond_val = String.to_integer(cond_val)

      reg_val = Map.get(registers, reg, 0)
      cond_reg_val = Map.get(registers, cond_reg, 0)

      if check_condition(cond_reg_val, cond_op, cond_val) do
        new_val = case op do
          "inc" -> reg_val + amount
          "dec" -> reg_val - amount
        end

        new_registers = Map.put(registers, reg, new_val)
        new_max = max(max_ever, new_val)
        {new_registers, new_max}
      else
        {registers, max_ever}
      end
    end)
  end

  defp check_condition(a, ">", b), do: a > b
  defp check_condition(a, "<", b), do: a < b
  defp check_condition(a, ">=", b), do: a >= b
  defp check_condition(a, "<=", b), do: a <= b
  defp check_condition(a, "==", b), do: a == b
  defp check_condition(a, "!=", b), do: a != b
end
