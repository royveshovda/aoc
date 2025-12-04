defmodule Solve do
  def apply_rotation(position, {"L", distance}) do
    rem(position - distance + 100, 100)
  end

  def apply_rotation(position, {"R", distance}) do
    rem(position + distance, 100)
  end

  def count_zeros_detailed(position, {direction, distance}) do
    positions = case direction do
      "L" ->
        for i <- 1..distance do
          rem(position - i + 100, 100)
        end
      "R" ->
        for i <- 1..distance do
          rem(position + i, 100)
        end
    end
    
    Enum.count(positions, &(&1 == 0))
  end

  def solve(input) do
    rotations = input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      <<dir::binary-size(1), rest::binary>> = line
      {dir, String.to_integer(rest)}
    end)

    {_final, total} = Enum.reduce(rotations, {50, 0}, fn rotation, {pos, count} ->
      zeros = count_zeros_detailed(pos, rotation)
      new_pos = apply_rotation(pos, rotation)
      {new_pos, count + zeros}
    end)

    total
  end
end

input = File.read!("input/2025_1.txt")
result = Solve.solve(input)
IO.puts("Answer: #{result}")
