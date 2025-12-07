import AOC

aoc 2025, 7 do
  @moduledoc """
  https://adventofcode.com/2025/day/7

  Tachyon beam simulation:
  - Beam starts at S and moves downward
  - When beam hits ^ splitter, it stops and two new beams continue from left and right
  - Count total splits (Part 1) or something else for Part 2
  """

  @doc """
      iex> p1(example_string(0))
      21
  """
  def p1(input) do
    {grid, start_x, max_y} = parse(input)

    # Start with a single beam at position S, moving down
    simulate(grid, [{start_x, 0}], max_y, 0)
  end

  defp parse(input) do
    lines = input |> String.split("\n", trim: true)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Map.new()

    # Find starting position (S)
    {start_x, _} =
      grid
      |> Enum.find(fn {_pos, char} -> char == "S" end)
      |> elem(0)

    max_y = length(lines) - 1

    {grid, start_x, max_y}
  end

  defp simulate(_grid, [], _max_y, splits), do: splits

  defp simulate(grid, beams, max_y, splits) do
    # Move all beams down one step and process
    {new_beams, new_splits} =
      beams
      |> Enum.reduce({MapSet.new(), 0}, fn {x, y}, {acc_beams, acc_splits} ->
        next_y = y + 1

        if next_y > max_y do
          # Beam exits the grid
          {acc_beams, acc_splits}
        else
          case Map.get(grid, {x, next_y}, ".") do
            "^" ->
              # Splitter! Stop this beam, emit two new beams from left and right
              {acc_beams |> MapSet.put({x - 1, next_y}) |> MapSet.put({x + 1, next_y}),
               acc_splits + 1}

            _ ->
              # Empty space or other, continue downward
              {MapSet.put(acc_beams, {x, next_y}), acc_splits}
          end
        end
      end)

    simulate(grid, MapSet.to_list(new_beams), max_y, splits + new_splits)
  end

  @doc """
      iex> p2(example_string(0))
      40
  """
  def p2(input) do
    {grid, start_x, max_y} = parse(input)

    # Start with 1 timeline at position S
    # Track position -> number of timelines at that position
    simulate_timelines(grid, %{{start_x, 0} => 1}, max_y)
  end

  defp simulate_timelines(_grid, positions, _max_y) when map_size(positions) == 0 do
    0
  end

  defp simulate_timelines(grid, positions, max_y) do
    # Move all particles down one step
    # Each position has a count of timelines at that position
    {new_positions, finished_timelines} =
      positions
      |> Enum.reduce({%{}, 0}, fn {{x, y}, timeline_count}, {acc_pos, acc_finished} ->
        next_y = y + 1

        if next_y > max_y do
          # Particle exits - these timelines are done
          {acc_pos, acc_finished + timeline_count}
        else
          case Map.get(grid, {x, next_y}, ".") do
            "^" ->
              # Splitter! Each timeline splits into 2
              # Left and right each get the full timeline count
              acc_pos =
                acc_pos
                |> Map.update({x - 1, next_y}, timeline_count, &(&1 + timeline_count))
                |> Map.update({x + 1, next_y}, timeline_count, &(&1 + timeline_count))

              {acc_pos, acc_finished}

            _ ->
              # Empty space, continue downward
              {Map.update(acc_pos, {x, next_y}, timeline_count, &(&1 + timeline_count)),
               acc_finished}
          end
        end
      end)

    finished_timelines + simulate_timelines(grid, new_positions, max_y)
  end
end
