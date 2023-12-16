import AOC

aoc 2023, 16 do
  @moduledoc """
  https://adventofcode.com/2023/day/16
  """

  @doc """
      #iex> p1(example_string())
      #123

      #iex> p1(input_string())
      #123
  """
  def p1(input) do
    input
    |> parse_input()
  end

  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse_input()
  end

  def parse_input(input) do
    for {line, row} <- Enum.with_index(input |> String.split("\n")),
      {point, col} <- Enum.with_index(String.graphemes(line)),
      into: %{} do
        {{row, col}, point}
    end
  end

  def move({:right, row, col}, ".", {max_row, max_col}) do
    [{:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:left, row, col}, ".", {max_row, max_col}) do
    [{:left, row, col - 1}] |> roll_over({max_row, max_col})
  end

  def move({:down, row, col}, ".", {max_row, max_col}) do
    [{:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:up, row, col}, ".", {max_row, max_col}) do
    [{:up, row - 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:right, row, col}, "/", {max_row, max_col}) do
    [{:up, row - 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:left, row, col}, "/", {max_row, max_col}) do
    [{:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:down, row, col}, "/", {max_row, max_col}) do
    [{:left, row, col - 1}] |> roll_over({max_row, max_col})
  end

  def move({:up, row, col}, "/", {max_row, max_col}) do
    [{:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:right, row, col}, "\\", {max_row, max_col}) do
    [{:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:left, row, col}, "\\", {max_row, max_col}) do
    [{:up, row - 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:down, row, col}, "\\", {max_row, max_col}) do
    [{:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:up, row, col}, "\\", {max_row, max_col}) do
    [{:left, row, col - 1}] |> roll_over({max_row, max_col})
  end

  def move({:right, row, col}, "-", {max_row, max_col}) do
    [{:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:left, row, col}, "-", {max_row, max_col}) do
    [{:left, row, col - 1}] |> roll_over({max_row, max_col})
  end

  def move({:down, row, col}, "-", {max_row, max_col}) do
    [{:left, row, col - 1}, {:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:up, row, col}, "-", {max_row, max_col}) do
    [{:left, row, col - 1}, {:right, row, col + 1}] |> roll_over({max_row, max_col})
  end

  def move({:right, row, col}, "|", {max_row, max_col}) do
    [{:up, row - 1, col}, {:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:left, row, col}, "|", {max_row, max_col}) do
    [{:up, row - 1, col}, {:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:down, row, col}, "|", {max_row, max_col}) do
    [{:down, row + 1, col}] |> roll_over({max_row, max_col})
  end

  def move({:up, row, col}, "|", {max_row, max_col}) do
    [{:up, row - 1, col}] |> roll_over({max_row, max_col})
  end


  def roll_over(points, {max_row, max_col}) do
    Enum.map(points, fn {dir, row, col} ->
      single_roll_over({dir, row, col}, {max_row, max_col}) end)
  end


  def single_roll_over({dir, row, col}, {max_row, max_col}) do
    case {row, col} do
      {row, col} when row < 0 -> {dir, max_row, col}
      {row, col} when row > max_row -> {dir, 0, col}
      {row, col} when col < 0 -> {dir, row, max_col}
      {row, col} when col > max_col -> {dir, row, 0}
      {row, col} -> {dir, row, col}
    end
  end
end
