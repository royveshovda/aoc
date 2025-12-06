import AOC

aoc 2022, 10 do
  @moduledoc """
  Day 10: Cathode-Ray Tube

  Simple CPU with X register and addx/noop instructions.
  Part 1: Sum signal strengths at cycles 20, 60, 100, 140, 180, 220.
  Part 2: Render 40x6 CRT display based on sprite position.
  """

  @doc """
  Part 1: Sum of signal strengths at specific cycles.

  ## Examples

      iex> p1("noop\\naddx 3\\naddx -5")
      0
  """
  def p1(input) do
    check_cycles = MapSet.new([20, 60, 100, 140, 180, 220])

    {_x, _cycle, signal_sum} =
      input
      |> parse()
      |> Enum.reduce({1, 1, 0}, fn instruction, {x, cycle, signal_sum} ->
        case instruction do
          :noop ->
            signal_sum = maybe_add_signal(signal_sum, cycle, x, check_cycles)
            {x, cycle + 1, signal_sum}

          {:addx, v} ->
            signal_sum = maybe_add_signal(signal_sum, cycle, x, check_cycles)
            signal_sum = maybe_add_signal(signal_sum, cycle + 1, x, check_cycles)
            {x + v, cycle + 2, signal_sum}
        end
      end)

    signal_sum
  end

  @doc """
  Part 2: Render CRT output (returns 8 capital letters).
  """
  def p2(input) do
    instructions = parse(input)

    # Execute all instructions and collect (cycle, x) pairs
    {_x, _cycle, cycle_x_list} =
      Enum.reduce(instructions, {1, 1, []}, fn instruction, {x, cycle, acc} ->
        case instruction do
          :noop ->
            {x, cycle + 1, [{cycle, x} | acc]}

          {:addx, v} ->
            acc = [{cycle, x}, {cycle + 1, x} | acc]
            {x + v, cycle + 2, acc}
        end
      end)

    cycle_x_map = Map.new(cycle_x_list)

    # Render 40x6 grid
    pixels =
      for row <- 0..5, col <- 0..39 do
        cycle = row * 40 + col + 1
        x = Map.get(cycle_x_map, cycle, 1)
        sprite_positions = [x - 1, x, x + 1]

        if col in sprite_positions, do: "#", else: "."
      end

    pixels
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> ocr()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      case String.split(line, " ") do
        ["noop"] -> :noop
        ["addx", v] -> {:addx, String.to_integer(v)}
      end
    end)
  end

  defp maybe_add_signal(signal_sum, cycle, x, check_cycles) do
    if MapSet.member?(check_cycles, cycle) do
      signal_sum + cycle * x
    else
      signal_sum
    end
  end

  # Simple OCR for the specific letters in this puzzle
  defp ocr(display) do
    # Parse to identify which columns have # in which rows
    lines = String.split(display, "\n")

    # Extract 8 letters (each 5 wide including gap)
    0..7
    |> Enum.map(fn letter_idx ->
      start_col = letter_idx * 5

      pattern =
        lines
        |> Enum.map(fn line ->
          String.slice(line, start_col, 4)
        end)

      recognize_letter(pattern)
    end)
    |> Enum.join()
  end

  defp recognize_letter(pattern) do
    case pattern do
      ["####", "...#", "..#.", ".#..", "#...", "####"] -> "Z"
      [".##.", "#..#", "#..#", "####", "#..#", "#..#"] -> "A"
      ["###.", "#..#", "###.", "#..#", "#..#", "###."] -> "B"
      [".##.", "#..#", "#...", "#...", "#..#", ".##."] -> "C"
      ["####", "#...", "###.", "#...", "#...", "####"] -> "E"
      ["####", "#...", "###.", "#...", "#...", "#..."] -> "F"
      [".##.", "#..#", "#...", "#.##", "#..#", ".###"] -> "G"
      ["#..#", "#..#", "####", "#..#", "#..#", "#..#"] -> "H"
      [".###", "..#.", "..#.", "..#.", "..#.", ".###"] -> "I"
      ["..##", "...#", "...#", "...#", "#..#", ".##."] -> "J"
      ["#..#", "#.#.", "##..", "#.#.", "#.#.", "#..#"] -> "K"
      ["#...", "#...", "#...", "#...", "#...", "####"] -> "L"
      ["###.", "#..#", "#..#", "###.", "#...", "#..."] -> "P"
      ["###.", "#..#", "#..#", "###.", "#.#.", "#..#"] -> "R"
      ["#..#", "#..#", "#..#", "#..#", "#..#", ".##."] -> "U"
      _ -> "?"
    end
  end
end
