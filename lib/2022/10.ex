import AOC

aoc 2022, 10 do

  @screen_width 40

  @doc """
  1. The first line contains the number of instructions.
  2. The next N lines contain the instructions.
  3. The last line contains the signal.
      iex> Y2022.D10.p1(Y2022.D10.example_string())
      13140

      iex> Y2022.D10.p1(Y2022.D10.input_string())
      12460
  """
  def p1(input) do

    values =
      input
      |> String.split("\n")
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(&read/1)
      |> Enum.flat_map(&expand/1)
      |> List.insert_at(0, 1)

    signal = [20,60,100,140,180,220]

    signal
    |> Enum.map(fn v -> ((Enum.take(values, v) |> Enum.sum())) * v end)
    |> Enum.sum()
  end

  def read(["addx", value]), do: {:addx, String.to_integer(value)}
  def read(["noop"]), do: {:noop}

  def expand({:addx, value}), do: [0, value]
  def expand({:noop}), do: [0]

  def parse_instruction(instruction, values \\ [1])

  def parse_instruction("noop", [value | _] = values) do
    [value | values]
  end

  def parse_instruction("addx " <> amount, [current | _] = values) do
    amount = String.to_integer(amount)
    [amount + current | [current | values]]
  end

  def draw(instructions) do
    instructions
    |> Enum.map(&check_pixel/1)
    |> Enum.chunk_every(@screen_width)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
  end

  def check_pixel({location, index}) do
    index
    |> rem(@screen_width)
    |> Kernel.-(location)
    |> Kernel.abs()
    |> case do
      diff when diff <= 1 -> "█"
      _ -> " "
    end
  end

  def p2(input) do
    res =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce([1], &parse_instruction/2)
      |> Enum.reverse()
      |> Enum.with_index()
      |> draw()

    IO.puts(res)

    res
  end
end
