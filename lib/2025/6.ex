import AOC

aoc 2025, 6 do
  @moduledoc """
  https://adventofcode.com/2025/day/6

  Problems are arranged vertically in columns.
  Problems are separated by columns that contain only spaces.
  The bottom row contains the operator (+ or *) for each problem.
  """

  @doc """
      iex> p1(example_string(0))
      4277556
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string(0))
      3263827
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.reverse()  # Read problems right-to-left
    |> Enum.map(&solve_problem_p2/1)
    |> Enum.sum()
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    # Convert each line to a list of characters, padding to same length
    char_lines =
      lines
      |> Enum.map(&String.to_charlist/1)

    max_len = char_lines |> Enum.map(&length/1) |> Enum.max()

    # Pad all lines to the same length with spaces
    padded =
      char_lines
      |> Enum.map(fn line -> line ++ List.duplicate(?\s, max_len - length(line)) end)

    # Transpose to get columns
    columns = Enum.zip_with(padded, fn chars -> chars end)

    # Group columns into problems (separated by all-space columns)
    group_into_problems(columns, [], [])
  end

  defp group_into_problems([], [], acc), do: Enum.reverse(acc)
  defp group_into_problems([], current, acc), do: Enum.reverse([Enum.reverse(current) | acc])

  defp group_into_problems([col | rest], current, acc) do
    if Enum.all?(col, &(&1 == ?\s)) do
      # Separator column
      if current == [] do
        group_into_problems(rest, [], acc)
      else
        group_into_problems(rest, [], [Enum.reverse(current) | acc])
      end
    else
      group_into_problems(rest, [col | current], acc)
    end
  end

  defp solve_problem(columns) do
    # Transpose back to get rows for this problem
    rows = Enum.zip_with(columns, fn chars -> chars end)

    # Last row is the operator
    {number_rows, [op_row]} = Enum.split(rows, -1)

    # Get the operator (find + or *)
    operator = Enum.find(op_row, fn c -> c == ?+ or c == ?* end)

    # Parse numbers from each row
    numbers =
      number_rows
      |> Enum.map(fn row ->
        row
        |> List.to_string()
        |> String.trim()
        |> String.to_integer()
      end)

    # Apply the operation
    case operator do
      ?+ -> Enum.sum(numbers)
      ?* -> Enum.product(numbers)
    end
  end

  defp solve_problem_p2(columns) do
    # In Part 2:
    # - Each COLUMN represents a single number (not each row!)
    # - Numbers are read right-to-left within each problem
    # - Each digit in a column is read top-to-bottom (most significant at top)

    # Transpose back to get rows for this problem
    rows = Enum.zip_with(columns, fn chars -> chars end)

    # Last row is the operator
    {_digit_rows, [op_row]} = Enum.split(rows, -1)

    # Get the operator (find + or *)
    operator = Enum.find(op_row, fn c -> c == ?+ or c == ?* end)

    # Reverse columns (right-to-left reading)
    reversed_columns = Enum.reverse(columns)

    # Each column is a number, read top-to-bottom
    # Remove the operator row from each column first
    numbers =
      reversed_columns
      |> Enum.map(fn col ->
        # Remove the last element (operator row)
        {digit_chars, _} = Enum.split(col, -1)
        # Filter to just digits and convert to number
        digits =
          digit_chars
          |> Enum.filter(fn c -> c in ?0..?9 end)
          |> List.to_string()

        if digits == "" do
          nil
        else
          String.to_integer(digits)
        end
      end)
      |> Enum.reject(&is_nil/1)

    # Apply the operation
    case operator do
      ?+ -> Enum.sum(numbers)
      ?* -> Enum.product(numbers)
    end
  end
end
