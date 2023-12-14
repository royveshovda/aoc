import AOC

aoc 2023, 14 do
  @moduledoc """
  https://adventofcode.com/2023/day/14
  """

  @doc """
      iex> p1(example_string())
      136

      iex> p1(input_string())
      102497
  """
  def p1(input) do
    {grid, max_row, max_col} =
      input
      |> parse()

    columns =
        for col <- 0..max_col,
          into: [] do
            for row <- 0..max_row do
              grid[{row, col}]
            end
          end

    columns
    |> Enum.map(fn col -> tilt_north(col, max_row) end)
    |> Enum.map(fn col -> Enum.filter(col, fn {_, p} -> p == "O" end) end)
    |> Enum.map(fn col -> Enum.map(col, fn {i, _} -> max_row - i + 1 end) end)
    |> Enum.map(fn col -> Enum.sum(col) end)
    |> Enum.sum()
  end

  def tilt_north(line, max_row) do
    l2 = Enum.with_index(line) |> Enum.map(fn {p, i} -> {i, p} end) |> Enum.into(%{})
    do_tilt_north(l2, 1, max_row)
    # TODO: consider to manupulate line here
  end

  def do_tilt_north(line, position_to_evaluate, max_row) when position_to_evaluate > max_row do
    line
  end

  def do_tilt_north(line, position_to_evaluate, max_row) do
    case line[position_to_evaluate] do
      "O" ->
        new_line = roll(line, position_to_evaluate)
        do_tilt_north(new_line, position_to_evaluate + 1, max_row)

      _ -> do_tilt_north(line, position_to_evaluate + 1, max_row)
    end
  end

  def roll(line, position_to_evaluate) do
    line
    |> Enum.filter(fn {i, _} -> i < position_to_evaluate end)
    case can_roll?(line, position_to_evaluate - 1) do
      false -> line
      {true, to_pos} ->
        %{line | position_to_evaluate => ".", to_pos => "O"}
    end
  end

  def can_roll?(line, -1), do: false
  def can_roll?(line, position_to_evaluate) do
    case line[position_to_evaluate] do
      "." ->
        case(line[position_to_evaluate - 1]) do
          "." -> can_roll?(line, position_to_evaluate - 1)
          _ -> {true, position_to_evaluate}
        end
      _ -> false
    end
  end

  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      #123
  """
  def p2(input) do
    input
    |> parse()
  end

  def parse(input) do
    grid =
      for {line, row} <- Enum.with_index(input |> String.split("\n")),
        {point, col} <- Enum.with_index(String.graphemes(line)),
        into: %{} do
          {{row, col}, point}
      end

    max_row = Enum.map(grid, fn {{r,_},_} -> r end) |> Enum.max()
    max_col = Enum.map(grid, fn {{_,c},_} -> c end) |> Enum.max()
    {grid, max_row, max_col}
  end
end
