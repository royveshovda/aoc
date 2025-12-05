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
    {instructions, network} = parse(input)
    steps_to_reach("AAA", instructions, network, fn node -> node == "ZZZ" end)
  end

  @doc """
      iex> p2(example_string_p2())
      6

      iex> p2(input_string())
      18625484023687
  """
  def p2(input) do
    {instructions, network} = parse(input)
    
    start_nodes = network |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))
    
    start_nodes
    |> Enum.map(fn start -> 
      steps_to_reach(start, instructions, network, &String.ends_with?(&1, "Z"))
    end)
    |> Enum.reduce(&lcm/2)
  end

  defp parse(input) do
    [instructions_line | network_lines] = String.split(input, "\n", trim: true)
    
    instructions = String.graphemes(instructions_line)
    
    network = network_lines
    |> Enum.map(fn line ->
      [node, left, right] = Regex.scan(~r/[A-Z0-9]+/, line) |> List.flatten()
      {node, {left, right}}
    end)
    |> Map.new()
    
    {instructions, network}
  end

  defp steps_to_reach(start, instructions, network, end_condition) do
    instructions
    |> Stream.cycle()
    |> Enum.reduce_while({start, 0}, fn dir, {node, steps} ->
      if end_condition.(node) do
        {:halt, steps}
      else
        {left, right} = network[node]
        next = if dir == "L", do: left, else: right
        {:cont, {next, steps + 1}}
      end
    end)
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))
  
  defp lcm(a, b), do: div(a * b, gcd(a, b))
end
