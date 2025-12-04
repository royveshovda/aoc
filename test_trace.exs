defmodule Trace do
  def apply_rotation(position, {"L", distance}) do
    rem(position - distance + 100, 100)
  end

  def apply_rotation(position, {"R", distance}) do
    rem(position + distance, 100)
  end

  def count_zeros(position, {direction, distance}) do
    case direction do
      "L" ->
        if distance >= position && position > 0 do
          1 + div(distance - position, 100)
        else
          0
        end
      "R" ->
        if distance >= 100 - position && position > 0 do
          1 + div(distance - (100 - position), 100)
        else
          0
        end
    end
  end

  def trace do
    rotations = [
      {"L", 68}, {"L", 30}, {"R", 48}, {"L", 5}, {"R", 60},
      {"L", 55}, {"L", 1}, {"L", 99}, {"R", 14}, {"L", 82}
    ]

    {_final, total, _} = Enum.reduce(rotations, {50, 0, []}, fn rotation, {pos, count, trace} ->
      zeros = count_zeros(pos, rotation)
      new_pos = apply_rotation(pos, rotation)
      new_trace = trace ++ [{rotation, pos, new_pos, zeros}]
      {new_pos, count + zeros, new_trace}
    end)

    IO.puts("Total: #{total}\n")
  end
end

Trace.trace()
