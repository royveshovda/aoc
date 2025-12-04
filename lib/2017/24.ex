import AOC

aoc 2017, 24 do
  @moduledoc """
  https://adventofcode.com/2017/day/24
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    components = parse(input)
    all_bridges = build_bridges(0, components, [])
    all_bridges |> Enum.map(&strength/1) |> Enum.max()
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    components = parse(input)
    all_bridges = build_bridges(0, components, [])

    max_length = all_bridges |> Enum.map(&length/1) |> Enum.max()
    longest = Enum.filter(all_bridges, fn b -> length(b) == max_length end)
    longest |> Enum.map(&strength/1) |> Enum.max()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b] = String.split(line, "/") |> Enum.map(&String.to_integer/1)
      {a, b}
    end)
  end

  defp build_bridges(port, available, bridge) do
    # Find all components that can connect to current port
    matching = Enum.filter(available, fn {a, b} -> a == port or b == port end)

    if Enum.empty?(matching) do
      [bridge]
    else
      Enum.flat_map(matching, fn component ->
        {a, b} = component
        next_port = if a == port, do: b, else: a
        remaining = List.delete(available, component)
        build_bridges(next_port, remaining, [component | bridge])
      end)
    end
  end

  defp strength(bridge) do
    Enum.reduce(bridge, 0, fn {a, b}, acc -> acc + a + b end)
  end
end
