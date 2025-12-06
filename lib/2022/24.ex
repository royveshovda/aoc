import AOC

aoc 2022, 24 do
  @moduledoc """
  Day 24: Blizzard Basin

  Navigate through valley with moving blizzards.
  Part 1: Shortest path from entrance to exit.
  Part 2: Round trip (exit -> entrance -> exit).
  """

  @doc """
  Part 1: Fewest minutes to reach goal.

  ## Examples

      iex> example = \"\"\"
      ...> #.######
      ...> #>>.<^<#
      ...> #.<..<<#
      ...> #>v.><>#
      ...> #<^v^^>#
      ...> ######.#
      ...> \"\"\"
      iex> Y2022.D24.p1(example)
      18
  """
  def p1(input) do
    {blizzards, width, height} = parse(input)
    start = {-1, 0}
    goal = {height - 1, width - 1}

    {time, _blizzards} = walk(1, [start], blizzards, width, height, goal)
    time
  end

  @doc """
  Part 2: Round trip time (start -> end -> start -> end).

  ## Examples

      iex> example = \"\"\"
      ...> #.######
      ...> #>>.<^<#
      ...> #.<..<<#
      ...> #>v.><>#
      ...> #<^v^^>#
      ...> ######.#
      ...> \"\"\"
      iex> Y2022.D24.p2(example)
      54
  """
  def p2(input) do
    {blizzards, width, height} = parse(input)
    start = {-1, 0}
    goal = {height - 1, width - 1}

    # Trip 1: start to goal
    {time1, blizzards} = walk(1, [start], blizzards, width, height, goal)

    # Trip 2: goal to start (need to step blizzards once for leaving goal)
    blizzards = step_blizzards(blizzards, width, height)
    {time2, blizzards} = walk(time1 + 1, [goal], blizzards, width, height, start)

    # Trip 3: start to goal again
    blizzards = step_blizzards(blizzards, width, height)
    {time3, _} = walk(time2 + 1, [start], blizzards, width, height, goal)

    time3
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    width = String.length(hd(lines)) - 2
    height = length(lines) - 2

    blizzards =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {ch, col} -> parse_char(ch, row - 1, col - 1) end)
        |> Enum.reject(&is_nil/1)
      end)

    {blizzards, width, height}
  end

  defp parse_char(?>, row, col), do: {row, col, 0, 1}
  defp parse_char(?<, row, col), do: {row, col, 0, -1}
  defp parse_char(?^, row, col), do: {row, col, -1, 0}
  defp parse_char(?v, row, col), do: {row, col, 1, 0}
  defp parse_char(_, _, _), do: nil

  defp walk(step, positions, blizzards, width, height, target) do
    if target in positions do
      {step, blizzards}
    else
      new_blizzards = step_blizzards(blizzards, width, height)
      blocked = new_blizzards |> Enum.map(fn {r, c, _, _} -> {r, c} end) |> MapSet.new()

      new_positions =
        positions
        |> Enum.flat_map(&neighbors(&1, width, height))
        |> Enum.reject(&MapSet.member?(blocked, &1))
        |> Enum.uniq()

      if new_positions == [] do
        raise "No valid positions!"
      end

      walk(step + 1, new_positions, new_blizzards, width, height, target)
    end
  end

  defp step_blizzards(blizzards, width, height) do
    Enum.map(blizzards, fn {row, col, dr, dc} ->
      {rem(row + dr + height, height), rem(col + dc + width, width), dr, dc}
    end)
  end

  defp neighbors({row, col}, width, height) do
    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}, {row, col}]
    |> Enum.filter(&valid_pos?(&1, width, height))
  end

  # Start position (above grid)
  defp valid_pos?({-1, 0}, _width, _height), do: true
  # Goal position (below grid)
  defp valid_pos?({height, col}, width, height) when col == width - 1, do: true
  # Out of bounds
  defp valid_pos?({row, col}, _width, _height) when row < 0 or col < 0, do: false
  defp valid_pos?({row, col}, width, height) when row >= height or col >= width, do: false
  # Valid grid position
  defp valid_pos?(_, _, _), do: true
end
