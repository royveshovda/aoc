import AOC

aoc 2025, 1 do
  @moduledoc """
  https://adventofcode.com/2025/day/1
  """

  @doc """
      iex> p1(example_string(0))
      3
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rotation/1)
    |> Enum.reduce({50, 0}, fn rotation, {position, count} ->
      new_position = apply_rotation(position, rotation)
      new_count = if new_position == 0, do: count + 1, else: count
      {new_position, new_count}
    end)
    |> elem(1)
  end

  defp parse_rotation(line) do
    <<direction::binary-size(1), rest::binary>> = line
    distance = String.to_integer(rest)
    {direction, distance}
  end

  defp apply_rotation(position, {"L", distance}) do
    rem(position - distance + 100, 100)
  end

  defp apply_rotation(position, {"R", distance}) do
    rem(position + distance, 100)
  end

  @doc """
      iex> p2(example_string(0))
      6
  """
  def p2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rotation/1)
    |> Enum.reduce({50, 0}, fn rotation, {position, count} ->
      clicks_through_zero = count_zeros_during_rotation(position, rotation)
      new_position = apply_rotation(position, rotation)
      {new_position, count + clicks_through_zero}
    end)
    |> elem(1)
  end

  defp count_zeros_during_rotation(position, {direction, distance}) do
    # Count how many times we click through or land on 0 during rotation
    new_pos = apply_rotation(position, {direction, distance})

    case direction do
      "L" ->
        # Moving left/decreasing
        if new_pos < position do
          # No wrap: going from position down to new_pos, never hit 0
          0
        else
          # Wrapped around: crossed through 0 one or more times
          # Total clicks = distance
          # We go from position to 0 (that's position clicks),
          # then continue wrapping
          div(distance, 100) + if(position >= distance, do: 0, else: 1)
        end

      "R" ->
        # Moving right/increasing
        if new_pos > position do
          # No wrap: going from position up to new_pos, never hit 0
          0
        else
          # Wrapped around: crossed through 0 one or more times
          # We need to reach 100 first (100-position clicks), then continue
          div(distance + position, 100)
        end
    end
  end
end
