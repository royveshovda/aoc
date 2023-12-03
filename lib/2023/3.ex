import AOC

aoc 2023, 3 do
  @moduledoc """
  https://adventofcode.com/2023/day/3
  """

  @doc """
      iex> p1(example_string())
      4361

      #iex> p1(input_string())
      #321
  """
  def p1(input) do
    # parse input into array
    # loop over whole array
    # keep track of visited numbers
    # check if number is in visited numbers
    # if not expand to find all other numbers on same line
    # check if number has any adjacent symbols
    # if yes, add number to part number list
    grid =
      input
      |> parse()

    expand_pos(grid, {0,0}, [], [])
  end

  @doc """
      #iex> p2(example_string())
      #123

      #iex> p2(input_string())
      3321

  """
  def p2(input) do
    input
  end

  defp parse(input) do
    for {line, row} <- Enum.with_index(input |> String.split("\n")),
        {value, col} <- Enum.with_index(String.graphemes(line)),
        into: %{} do
      {{row, col}, value}
    end
  end

  def number?(char) do
    char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  end

  def symbol?(char) do
    char in ["&", "*", "/", "-", "%", "=", "@", "$", "#", "+"]
  end

  def expand_pos(grid, coord, visited, parts) do
    # check if number is in visited numbers
    case visited?(coord, visited) do
      true -> {grid, visited, parts} # do nothing
      false ->
        case (number?(grid[coord])) do
          true -> # add to visited and parts
            expand_number_in_pos(grid, coord, visited, parts)
          false -> # add to visited and parts
            {grid, visited, parts}
        end
        # if not expand to find all other numbers on same line
        # check if number has any adjacent symbols
        # if yes, add number to part number list
        {grid, visited, parts}
    end
    # if not expand to find all other numbers on same line
    # check if number has any adjacent symbols
    # if yes, add number to part number list
    {grid, visited, parts}
  end

  def expand_number_in_pos(grid, coord, visited, parts) do
    # add to visited and parts
    {grid, visited, parts}
  end

  def visited?(coord, visited) do
    coord in visited
  end
end
