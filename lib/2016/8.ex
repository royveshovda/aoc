import AOC

aoc 2016, 8 do
  @moduledoc """
  https://adventofcode.com/2016/day/8
  Day 8: Two-Factor Authentication - LCD screen simulation
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    input
    |> execute_instructions()
    |> Map.values()
    |> Enum.count(& &1)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    grid = execute_instructions(input)
    "\n" <> display_grid(grid)
  end

  defp execute_instructions(input) do
    instructions = input |> String.trim() |> String.split("\n", trim: true)

    Enum.reduce(instructions, init_grid(), fn instr, grid ->
      execute_instruction(grid, instr)
    end)
  end

  defp init_grid do
    for x <- 0..49, y <- 0..5, into: %{}, do: {{x, y}, false}
  end

  defp execute_instruction(grid, "rect " <> rest) do
    [a, b] = rest |> String.split("x") |> Enum.map(&String.to_integer/1)

    for x <- 0..(a - 1), y <- 0..(b - 1), reduce: grid do
      acc -> Map.put(acc, {x, y}, true)
    end
  end

  defp execute_instruction(grid, "rotate row y=" <> rest) do
    [row, shift] = rest |> String.split(" by ") |> Enum.map(&String.to_integer/1)

    old_values = for x <- 0..49, do: {x, grid[{x, row}]}

    Enum.reduce(old_values, grid, fn {x, val}, acc ->
      new_x = rem(x + shift, 50)
      Map.put(acc, {new_x, row}, val)
    end)
  end

  defp execute_instruction(grid, "rotate column x=" <> rest) do
    [col, shift] = rest |> String.split(" by ") |> Enum.map(&String.to_integer/1)

    old_values = for y <- 0..5, do: {y, grid[{col, y}]}

    Enum.reduce(old_values, grid, fn {y, val}, acc ->
      new_y = rem(y + shift, 6)
      Map.put(acc, {col, new_y}, val)
    end)
  end

  defp display_grid(grid) do
    for y <- 0..5 do
      for x <- 0..49 do
        if grid[{x, y}], do: "#", else: " "
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end
end
