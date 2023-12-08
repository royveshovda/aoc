import AOC

aoc 2023, 8 do
  @moduledoc """
  https://adventofcode.com/2023/day/8
  """

  @doc """
      iex> p1(example_string())
      2

      iex> p1(input_string())
      17287
  """
  def p1(input) do
    {instructions, map} = parse(input)
    #map[:AAA][:left]

    i =
      instructions
      |> Stream.cycle()

    #IO.inspect(map)

    start = :AAA
    finish = :ZZZ
    Enum.reduce_while(i, {start, 0}, fn instruction, {from, steps} ->
      case from do
        :ZZZ -> {:halt, steps}
        _ ->
          next = move(map, from, instruction)
          #IO.inspect(next)
          {:cont, {next, steps + 1}}
      end
    end)
  end

  def move(map, from, instruction) do
    case instruction do
      :L -> map[from][:left]
      :R -> map[from][:right]
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
  end

  def parse(input) do
    [instructions_string, map_string] = String.split(input, "\n\n")
    instructions = String.graphemes(instructions_string) |> Enum.map(&String.to_atom/1)
    map =
      map_string
      |> String.split("\n")
      |> Enum.map(fn line ->
        [start, value] = String.split(line, " = ")
        [left, right] =
          value
          |> String.trim("(")
          |> String.trim(")")
          |> String.split(", ", trim: true)
          |> Enum.map(&String.to_atom/1)
        {String.to_atom(start), %{left: left, right: right}}
      end)
      |> Map.new()
    {instructions, map}
  end
end
