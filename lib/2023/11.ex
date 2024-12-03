import AOC

aoc 2023, 11 do
  @moduledoc """
  https://adventofcode.com/2023/day/11
  """

  @doc """
      iex> p1(example_string())
      374

      iex> p1(input_string())
      9795148
  """
  def p1(input) do
    {galaxies, rows_to_expand, cols_to_expand} = parse(input)

    expanded_galaxies =
      galaxies
      |> Enum.map(fn {r, c} ->

        rows_to_add = Enum.count(rows_to_expand, fn row -> row < r end)
        cols_to_add = Enum.count(cols_to_expand, fn col -> col < c end)
        {r + rows_to_add, c + cols_to_add}
       end)

    pairs = combinations(2, expanded_galaxies)

    pairs
    |> Enum.map(fn [g1, g2] -> calculate_distance(g1, g2) end)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string(), 10)
      1030

      iex> p2(example_string(), 100)
      8410

      iex> p2(input_string())
      650672493820
  """
  def p2(input, expansion_rate \\ 1_000_000) do
    {galaxies, rows_to_expand, cols_to_expand} = parse(input)

    expanded_galaxies =
      galaxies
      |> Enum.map(fn {r, c} ->

        rows_to_add = Enum.count(rows_to_expand, fn row -> row < r end)
        cols_to_add = Enum.count(cols_to_expand, fn col -> col < c end)
        # remeber to add the expansion rate and subtract the rows_to_add/cols_to_add
        # because we are replacing the galaxy with a bigger one, not just multiplying
        {r + (rows_to_add * expansion_rate - rows_to_add), c + (cols_to_add * expansion_rate - cols_to_add)}
       end)

    pairs = combinations(2, expanded_galaxies)

    pairs
    |> Enum.map(fn [g1, g2] -> calculate_distance(g1, g2) end)
    |> Enum.sum()
  end

  def parse(input) do
    grid =
      for {line, row} <- Enum.with_index(input |> String.split("\n")),
          {point, col} <- Enum.with_index(String.graphemes(line)),
          into: %{} do
        {{row, col}, point}
      end

    # find all rows to expand
    max_row = Enum.map(grid, fn {{r, _}, _} -> r end) |> Enum.max()

    rows_to_expand =
      (0..max_row)
      |> Enum.map(fn row_id -> {row_id, Enum.filter(grid, fn {{r, _}, _} -> r == row_id end)} end)
      |> Enum.filter(fn {_row_id, rows} -> Enum.all?(rows, fn {{_, _} , v} -> v == "." end) end)
      |> Enum.map(fn {row_id, _} -> row_id end)

    max_cols = Enum.map(grid, fn {{_, c}, _} -> c end) |> Enum.max()

    cols_to_expand =
      (0..max_cols)
      |> Enum.map(fn col_id -> {col_id, Enum.filter(grid, fn {{_, c}, _} -> c == col_id end)} end)
      |> Enum.filter(fn {_col_id, cols} -> Enum.all?(cols, fn {{_, _} ,v} -> v == "." end) end)
      |> Enum.map(fn {col_id, _} -> col_id end)

    galaxies =
      grid
      |> Enum.filter(fn {{_, _} ,v} -> v == "#" end)
      |> Enum.map(fn {{r, c}, _} -> {r, c} end)

    {galaxies, rows_to_expand, cols_to_expand}
  end

  defp calculate_distance({r1, c1}, {r2, c2}) do
    abs(r1 - r2) + abs(c1 - c2)
  end

  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []
  defp combinations(size, [head | tail]) do
      (for elem <- combinations(size - 1, tail), do: [head|elem]) ++ combinations(size, tail)
  end
end
