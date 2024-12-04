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

    start = :AAA
    #finish = :ZZZ
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
      iex> p2(example_string_p2())
      6

      iex> p2(input_string())
      18625484023687
  """
  def p2(input) do
    {instructions, map} = parse(input)

    i =
      instructions
      |> Stream.cycle()

    start_nodes =
      map
      |> Map.keys()
      |> Enum.filter(fn node -> to_string(node) |> String.graphemes() |> (fn [_l1, _l2, l3] -> l3 == "A" end).() end)

    finish_nodes =
      map
      |> Map.keys()
      |> Enum.filter(fn node -> to_string(node) |> String.graphemes() |> (fn [_l1, _l2, l3] -> l3 == "Z" end).() end)

    Enum.map(start_nodes, fn start ->
      Enum.reduce_while(i, {start, 0, 0, []}, fn instruction, {from, steps, bumps, stops} ->
        next = move(map, from, instruction)
        case from in finish_nodes do
          true ->
            #IO.puts("Found path at #{from} at #{steps}")
            case bumps do
              1 -> {:halt, {steps, [steps | stops]}}
              _ -> {:cont, {next, steps + 1, bumps + 1, [steps | stops]}}
            end
          _ -> {:cont, {next, steps + 1, bumps, stops}}
        end
      end)
    end)
    |> Enum.map(fn {_steps, [_stop1, stop2]} ->
      stop2
    end)
    |> Enum.reduce(&lcm/2)
  end

  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  def example_string_p2() do
    """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
  end

  def parse(input) do
    [instructions_string, map_string] = String.split(input, "\n\n")
    instructions = String.graphemes(instructions_string) |> Enum.map(&String.to_atom/1)
    map =
      map_string
      |> String.split("\n", trim: true)
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
