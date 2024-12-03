import AOC

aoc 2019, 2 do
  def p1(input) do
    instructions =
      input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, i} -> {i, v} end)
      |> Map.new()

    instructions
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> run(0)
    |> Map.get(0)
  end

  def run(instructions, i) do
    case instructions[i] do
      1 ->
        u = add(instructions, i)
        run(u, i + 4)
      2 ->
        u = multiply(instructions, i)
        run(u, i + 4)
      99 -> instructions
    end
  end

  def add(instructions, i) do
    Map.put(instructions, instructions[i + 3], instructions[instructions[i+1]] + instructions[instructions[i+2]])
  end

  def multiply(instructions, i) do
    Map.put(instructions, instructions[i + 3], instructions[instructions[i + 1]] * instructions[instructions[i + 2]])
  end

  def p2(input) do
    instructions =
      input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, i} -> {i, v} end)
      |> Map.new()

    l = length(Map.keys(instructions)) - 1
    options = for n <- 0..l, v <- 0..l, do: {n, v}

    {n, y} =
      options
      |> Enum.find(fn {n, v} ->
        instructions
        |> Map.put(1, n)
        |> Map.put(2, v)
        |> run(0)
        |> Map.get(0) == 19690720
      end)

    100 * n + y
  end
end
