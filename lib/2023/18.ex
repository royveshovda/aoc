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
      |> parse_input()

    {edge, _stop_position} = create_edge(instructions)

    edge_length = length(edge |> Map.keys())
    IO.puts("edge length: #{edge_length}")
    fill = flood_fill(edge, [{1,1}], %{})
    fill_length = length(fill |> Map.keys())

    edge_length + fill_length
    #print_edge(edge)
  end

  def flood_fill(_edge, [], fill) do
    fill
  end

  def flood_fill(edge, [{row, col} | rest], fill) do
    case Map.has_key?(fill, {row, col}) do
      true -> flood_fill(edge, rest, fill)
      false ->
        new_next =
          [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
          |> Enum.filter(fn p -> !Map.has_key?(fill, p) end)
          |> Enum.filter(fn p -> !Map.has_key?(edge, p) end)
        new_fill = Map.put(fill, {row, col}, "#")
        flood_fill(edge, rest ++ new_next, new_fill)
    end
  end

  def print_edge(edge) do
    IO.puts("print edge")
    min_row = edge |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.min()
    max_row = edge |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.max()
    min_col = edge |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.min()
    max_col = edge |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.max()

    for row <- min_row..max_row do
      for col <- min_col..max_col do
        case Map.get(edge, {row, col}) do
          nil -> IO.write(".")
          #color -> IO.write(color)
          _color -> IO.write("#")
        end
      end
      IO.puts("")
    end
  end

  def create_edge(instructions) do
    instructions
    |> Enum.reduce({%{}, {0,0}}, fn {op, length, color}, {edge, {current_row, current_col}} ->
      case op do
        "R" ->
          new_map =
            1..length
            |> Enum.map(fn i ->
              {{current_row, current_col + i}, color}
            end)
            |> Enum.into(edge)
          {new_map, {current_row, current_col + length}}
        "L" ->
          new_map =
            1..length
            |> Enum.map(fn i ->
              {{current_row, current_col - i}, color}
            end)
            |> Enum.into(edge)
          {new_map, {current_row, current_col - length}}
        "D" ->
          new_map =
            1..length
            |> Enum.map(fn i ->
              {{current_row + i, current_col}, color}
            end)
            |> Enum.into(edge)
          {new_map, {current_row + length, current_col}}
        "U" ->
          new_map =
            1..length
            |> Enum.map(fn i ->
              {{current_row - i, current_col}, color}
            end)
            |> Enum.into(edge)
          {new_map, {current_row - length, current_col}}
        _ ->
          {edge, {current_row, current_col}}
      end
    end)
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
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&parse_line/1)
  end

  def parse_line([op, length, color]) do
    color = color |> String.trim("(") |> String.trim(")") |> String.trim("#")
    {op, String.to_integer(length), color}
  end
end
