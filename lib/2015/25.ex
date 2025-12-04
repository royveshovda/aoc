import AOC

aoc 2015, 25 do
  @moduledoc """
  https://adventofcode.com/2015/day/25

  Day 25: Let It Snow

  Generate codes on an infinite diagonal grid using a mathematical sequence.
  """

  def p1(input) do
    {row, col} = parse_input(input)
    find_code(row, col)
  end

  def p2(_input) do
    "Merry Christmas! 🎄"
  end

  defp parse_input(input) do
    # Extract row and column from the input text
    case Regex.run(~r/row (\d+), column (\d+)/, input) do
      [_, row, col] -> {String.to_integer(row), String.to_integer(col)}
      _ -> {1, 1}
    end
  end

  defp find_code(row, col) do
    # Find which position in the sequence this is
    # The diagonal pattern fills: (1,1), (2,1), (1,2), (3,1), (2,2), (1,3), ...
    # Position formula: for (row, col), we need to find which diagonal it's on
    # and its position within that diagonal

    # The diagonal number is (row + col - 1)
    # Diagonals have 1, 2, 3, ... elements
    # Total elements in diagonals 1 through n is n*(n+1)/2

    # Elements before diagonal containing (row, col):
    diagonal = row + col - 1
    elements_before_diagonal = div((diagonal - 1) * diagonal, 2)

    # Position within the diagonal (counting from top)
    position_in_diagonal = col

    # Total position (1-indexed)
    position = elements_before_diagonal + position_in_diagonal

    # Generate the code at this position
    generate_code(position)
  end

  defp generate_code(position) do
    # Start: 20151125
    # Next: (prev * 252533) rem 33554393
    initial = 20151125
    multiplier = 252533
    modulo = 33554393

    # Generate position-1 more values
    1..(position - 1)
    |> Enum.reduce(initial, fn _, code ->
      rem(code * multiplier, modulo)
    end)
  end
end
