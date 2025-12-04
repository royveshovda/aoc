defmodule DetailedTrace do
  def apply_rotation(position, {"L", distance}) do
    rem(position - distance + 100, 100)
  end

  def apply_rotation(position, {"R", distance}) do
    rem(position + distance, 100)
  end

  def count_zeros_detailed(position, {direction, distance}) do
    # Generate all positions during the rotation
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

  def trace_example do
    rotations = [
      {"L", 68}, {"L", 30}, {"R", 48}, {"L", 5}, {"R", 60},
      {"L", 55}, {"L", 1}, {"L", 99}, {"R", 14}, {"L", 82}
    ]

    {_final, total} = Enum.reduce(rotations, {50, 0}, fn rotation, {pos, count} ->
      zeros = count_zeros_detailed(pos, rotation)
      new_pos = apply_rotation(pos, rotation)
      IO.puts("From #{pos}, #{elem(rotation, 0)}#{elem(rotation, 1)} -> #{new_pos}: #{zeros} zeros")
      {new_pos, count + zeros}
    end)

    IO.puts("\nTotal: #{total}")
  end
end

DetailedTrace.trace_example()
