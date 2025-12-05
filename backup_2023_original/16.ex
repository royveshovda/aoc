import AOC

aoc 2023, 16 do
  @moduledoc """
  https://adventofcode.com/2023/day/16
  """

  @doc """
      iex> p1(example_string())
      46

      iex> p1(input_string())
      7608
  """
  def p1(input) do
    start = [{:right, 0, 0}]

    grid =
      input
      |> parse_input()

    beam(grid, start, [])
    |> Enum.map(fn {_, row, col} -> {row, col} end)
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc """
      iex> p2(example_string())
      51

      iex> p2(input_string())
      8221
  """
  def p2(input) do
    grid =
      input
      |> parse_input()

    generate_start_points(grid)
    |> Task.async_stream(fn start ->
      beam(grid, [start], [])
      |> Enum.map(fn {_, row, col} -> {row, col} end)
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Enum.max()
  end

  def generate_start_points(grid) do
    max_col = grid |> Enum.map(fn {{_, col}, _} -> col end) |> Enum.max()
    max_row = grid |> Enum.map(fn {{row, _}, _} -> row end) |> Enum.max()

    top_edge = for col <- 0..max_col, into: [] do
      {:down, 0, col}
    end

    bottom_edge = for col <- 0..max_col, into: [] do
      {:up, max_row, col}
    end

    left_edge = for row <- 0..max_row, into: [] do
      {:right, row, 0}
    end

    right_edge = for row <- 0..max_row, into: [] do
      {:left, row, max_col}
    end

    top_edge ++ bottom_edge ++ left_edge ++ right_edge
  end

  def beam(_grid, [], energized) do
    energized
  end

  def beam(grid, [{_d, row, col} = move | moves], energized) do
    case move in energized do
      true -> beam(grid, moves, energized)
      _ ->
        case Map.has_key?(grid, {row, col}) do
          true -> beam(grid, move(move, grid[{row, col}]) ++ moves, [move|energized])
          _ -> beam(grid, moves, energized)
        end
    end
  end

  def parse_input(input) do
    for {line, row} <- Enum.with_index(input |> String.split("\n")),
      {point, col} <- Enum.with_index(String.graphemes(line)),
      into: %{} do
        {{row, col}, point}
    end
  end

  def move({:right, row, col}, "."), do: [{:right, row, col + 1}]
  def move({:left, row, col}, "."), do: [{:left, row, col - 1}]
  def move({:down, row, col}, "."), do: [{:down, row + 1, col}]
  def move({:up, row, col}, "."), do: [{:up, row - 1, col}]
  def move({:right, row, col}, "/"), do: [{:up, row - 1, col}]
  def move({:left, row, col}, "/"), do: [{:down, row + 1, col}]
  def move({:down, row, col}, "/"), do: [{:left, row, col - 1}]
  def move({:up, row, col}, "/"), do: [{:right, row, col + 1}]
  def move({:right, row, col}, "\\"), do: [{:down, row + 1, col}]
  def move({:left, row, col}, "\\"), do: [{:up, row - 1, col}]
  def move({:down, row, col}, "\\"), do: [{:right, row, col + 1}]
  def move({:up, row, col}, "\\"), do: [{:left, row, col - 1}]
  def move({:right, row, col}, "-"), do: [{:right, row, col + 1}]
  def move({:left, row, col}, "-"), do: [{:left, row, col - 1}]
  def move({:down, row, col}, "-"), do: [{:left, row, col - 1}, {:right, row, col + 1}]
  def move({:up, row, col}, "-"), do: [{:left, row, col - 1}, {:right, row, col + 1}]
  def move({:right, row, col}, "|"), do: [{:up, row - 1, col}, {:down, row + 1, col}]
  def move({:left, row, col}, "|"), do: [{:up, row - 1, col}, {:down, row + 1, col}]
  def move({:down, row, col}, "|"), do: [{:down, row + 1, col}]
  def move({:up, row, col}, "|"), do: [{:up, row - 1, col}]
end
