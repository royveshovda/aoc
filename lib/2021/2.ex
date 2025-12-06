import AOC

aoc 2021, 2 do
  @moduledoc """
  Day 2: Dive!

  Navigate submarine with forward/up/down commands.
  Part 1: Simple position tracking
  Part 2: Commands affect "aim" which modifies depth changes
  """

  @doc """
  Part 1: Track horizontal position and depth directly.
  - forward X increases horizontal position by X
  - down X increases depth by X
  - up X decreases depth by X
  Return: horizontal position * depth

  ## Examples

      iex> p1("forward 5\\ndown 5\\nforward 8\\nup 3\\ndown 8\\nforward 2")
      150
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.reduce({0, 0}, fn
      {:forward, x}, {h, d} -> {h + x, d}
      {:down, x}, {h, d} -> {h, d + x}
      {:up, x}, {h, d} -> {h, d - x}
    end)
    |> then(fn {h, d} -> h * d end)
  end

  @doc """
  Part 2: Use aim to control depth changes.
  - down X increases aim by X
  - up X decreases aim by X
  - forward X increases horizontal by X and depth by aim * X
  Return: horizontal position * depth

  ## Examples

      iex> p2("forward 5\\ndown 5\\nforward 8\\nup 3\\ndown 8\\nforward 2")
      900
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.reduce({0, 0, 0}, fn
      {:forward, x}, {h, d, aim} -> {h + x, d + aim * x, aim}
      {:down, x}, {h, d, aim} -> {h, d, aim + x}
      {:up, x}, {h, d, aim} -> {h, d, aim - x}
    end)
    |> then(fn {h, d, _aim} -> h * d end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, n] = String.split(line)
      {String.to_atom(dir), String.to_integer(n)}
    end)
  end
end
