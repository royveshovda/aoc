import AOC

aoc 2023, 18 do
  @moduledoc """
  https://adventofcode.com/2023/day/18
  """

  @doc """
      iex> p1(example_string())
      62

      iex> p1(input_string())
      56923
  """
  def p1(input) do
    instructions =
      input
      |> parse_input_p1()

    {edge, edge_length} = calculate_edge_length_and_polygons(instructions)
    fill_size = shoelace_area(edge)
    floor((edge_length / 2) + fill_size)
  end

  def calculate_edge_length_and_polygons(instructions) do
    {edge, _stop_position, edge_length} =
      instructions
      |> Enum.reduce({[], {0,0}, 0}, fn {op, length}, {edge, {current_row, current_col}, edge_length} ->
        new_edge_length = edge_length + length
        next_pos =
          case op do
            "R" ->
              {current_row, current_col + length}
            "L" ->
              {current_row, current_col - length}
            "D" ->
              {current_row + length, current_col}
            "U" ->
              {current_row - length, current_col}
          end
        new_edge = [{current_row, current_col} | edge]
        {new_edge, next_pos, new_edge_length}
      end)
    {edge, edge_length}
  end

  def shoelace_area(polygons) do
    n = length(polygons)
    0..n-1
    |> Enum.map(fn i ->
      {x1, y1} = polygons |> Enum.at(i)
      {x2, y2} = polygons |> Enum.at(rem(i + 1, n))
      x1 * y2 - x2 * y1
    end)
    |> Enum.sum()
    |> then(fn x -> (x / 2) + 1 end)
  end

  @doc """
      iex> p2(example_string())
      952408144115

      iex> p2(input_string())
      66296566363189
  """
  def p2(input) do
    instructions =
      input
      |> parse_input_p2()

    {edge, edge_length} = calculate_edge_length_and_polygons(instructions)
    fill_size = shoelace_area(edge)
    floor((edge_length / 2) + fill_size)
  end

  def parse_input_p1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&parse_line_p1/1)
  end

  def parse_line_p1([op, length, _color]) do
    {op, String.to_integer(length)}
  end

  def parse_input_p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&parse_line_p2/1)
  end

  def parse_line_p2([_fake_op, _fake_length, color]) do
    color = color |> String.trim("(") |> String.trim(")") |> String.trim("#")
    length = String.slice(color, 0..4) |> String.to_integer(16)
    op =
      case String.at(color, 5) do
        "0" -> "R"
        "1" -> "D"
        "2" -> "L"
        "3" -> "U"
      end
    {op, length}
  end
end
