import AOC

aoc 2022, 1 do
  @moduledoc """
  Day 1: Calorie Counting

  Find elf carrying most calories (sum of their food items).
  Part 2: Find sum of top 3 elves' calories.
  """

  @doc """
  Part 1: Find maximum calories carried by any single elf.

  ## Examples

      iex> example = \"\"\"
      ...> 1000
      ...> 2000
      ...> 3000
      ...>
      ...> 4000
      ...>
      ...> 5000
      ...> 6000
      ...>
      ...> 7000
      ...> 8000
      ...> 9000
      ...>
      ...> 10000
      ...> \"\"\"
      iex> p1(example)
      24000
  """
  def p1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn elf ->
      elf
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
    |> Enum.max()
  end

  @doc """
  Part 2: Find sum of calories carried by top 3 elves.

  ## Examples

      iex> example = \"\"\"
      ...> 1000
      ...> 2000
      ...> 3000
      ...>
      ...> 4000
      ...>
      ...> 5000
      ...> 6000
      ...>
      ...> 7000
      ...> 8000
      ...> 9000
      ...>
      ...> 10000
      ...> \"\"\"
      iex> p2(example)
      45000
  """
  def p2(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn elf ->
      elf
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
