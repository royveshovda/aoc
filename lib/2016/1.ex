import AOC

aoc 2016, 1 do
  @moduledoc """
  https://adventofcode.com/2016/day/1
  Day 1: No Time for a Taxicab
  Navigate city blocks following directions, calculate Manhattan distance.
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    input
    |> parse_instructions()
    |> follow_instructions()
    |> manhattan_distance()
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    input
    |> parse_instructions()
    |> find_first_visited_twice()
    |> manhattan_distance()
  end

  defp parse_instructions(input) do
    input
    |> String.trim()
    |> String.split(", ")
    |> Enum.map(fn <<dir::binary-size(1), dist::binary>> ->
      {dir, String.to_integer(dist)}
    end)
  end

  defp follow_instructions(instructions) do
    instructions
    |> Enum.reduce({{0, 0}, :north}, fn {turn, dist}, {pos, facing} ->
      new_facing = turn(facing, turn)
      new_pos = move(pos, new_facing, dist)
      {new_pos, new_facing}
    end)
    |> elem(0)
  end

  defp find_first_visited_twice(instructions) do
    instructions
    |> Enum.reduce_while({{0, 0}, :north, MapSet.new([{0, 0}])}, fn {turn, dist}, {pos, facing, visited} ->
      new_facing = turn(facing, turn)

      case find_first_duplicate(pos, new_facing, dist, visited) do
        {:found, dup_pos} -> {:halt, dup_pos}
        {:not_found, new_pos, new_visited} -> {:cont, {new_pos, new_facing, new_visited}}
      end
    end)
  end

  defp find_first_duplicate(pos, facing, dist, visited) do
    1..dist
    |> Enum.reduce_while({pos, visited}, fn _, {current_pos, vis} ->
      new_pos = move(current_pos, facing, 1)
      if MapSet.member?(vis, new_pos) do
        {:halt, {:found, new_pos}}
      else
        {:cont, {new_pos, MapSet.put(vis, new_pos)}}
      end
    end)
    |> case do
      {:found, pos} -> {:found, pos}
      {final_pos, final_visited} -> {:not_found, final_pos, final_visited}
    end
  end

  defp turn(:north, "R"), do: :east
  defp turn(:east, "R"), do: :south
  defp turn(:south, "R"), do: :west
  defp turn(:west, "R"), do: :north
  defp turn(:north, "L"), do: :west
  defp turn(:west, "L"), do: :south
  defp turn(:south, "L"), do: :east
  defp turn(:east, "L"), do: :north

  defp move({x, y}, :north, dist), do: {x, y + dist}
  defp move({x, y}, :south, dist), do: {x, y - dist}
  defp move({x, y}, :east, dist), do: {x + dist, y}
  defp move({x, y}, :west, dist), do: {x - dist, y}

  defp manhattan_distance({x, y}), do: abs(x) + abs(y)
end
