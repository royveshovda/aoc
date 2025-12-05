import AOC

aoc 2020, 3 do
  @moduledoc """
  https://adventofcode.com/2020/day/3

  Toboggan Trajectory - Navigate a repeating grid pattern counting trees hit.
  """

  @doc """
  Count trees encountered with slope right 3, down 1.

  ## Examples

      iex> input = "..##.......\\n#...#...#..\\n.#....#..#.\\n..#.#...#.#\\n.#...##..#.\\n..#.##.....\\n.#.#.#....#\\n.#........#\\n#.##...#...\\n#...##....#\\n.#..#...#.#"
      iex> p1(input)
      7
  """
  def p1(input) do
    grid = parse(input)
    count_trees(grid, 3, 1)
  end

  @doc """
  Check multiple slopes, multiply tree counts.

  ## Examples

      iex> input = "..##.......\\n#...#...#..\\n.#....#..#.\\n..#.#...#.#\\n.#...##..#.\\n..#.##.....\\n.#.#.#....#\\n.#........#\\n#.##...#...\\n#...##....#\\n.#..#...#.#"
      iex> p2(input)
      336
  """
  def p2(input) do
    grid = parse(input)
    slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

    slopes
    |> Enum.map(fn {right, down} -> count_trees(grid, right, down) end)
    |> Enum.product()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp count_trees(grid, right, down) do
    height = length(grid)
    width = length(hd(grid))

    0..(height - 1)
    |> Enum.take_every(down)
    |> Enum.with_index()
    |> Enum.count(fn {row, idx} ->
      col = rem(idx * right, width)
      Enum.at(Enum.at(grid, row), col) == "#"
    end)
  end
end
