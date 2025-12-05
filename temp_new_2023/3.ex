import AOC

aoc 2023, 3 do
  @moduledoc """
  https://adventofcode.com/2023/day/3
  """

  @doc """
      iex> p1(example_string())
      4361

      iex> p1(input_string())
      527364
  """
  def p1(input) do
    {numbers, symbols} = parse(input)
    
    numbers
    |> Enum.filter(fn {_num, coords} -> adjacent_to_symbol?(coords, symbols) end)
    |> Enum.map(fn {num, _} -> num end)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string())
      467835

      iex> p2(input_string())
      79026871
  """
  def p2(input) do
    {numbers, symbols} = parse(input)
    gears = symbols |> Enum.filter(fn {_, char} -> char == "*" end) |> Enum.map(&elem(&1, 0))
    
    gears
    |> Enum.map(fn gear_pos -> adjacent_numbers(gear_pos, numbers) end)
    |> Enum.filter(fn nums -> length(nums) == 2 end)
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    
    lines
    |> Enum.with_index()
    |> Enum.reduce({[], []}, fn {line, y}, {nums, syms} ->
      {line_nums, line_syms} = parse_line(line, y)
      {nums ++ line_nums, syms ++ line_syms}
    end)
  end

  defp parse_line(line, y) do
    chars = String.graphemes(line)
    
    {numbers, symbols, current_num} = 
      chars
      |> Enum.with_index()
      |> Enum.reduce({[], [], nil}, fn {char, x}, {nums, syms, cur} ->
        cond do
          char =~ ~r/\d/ ->
            case cur do
              nil -> {nums, syms, {[char], [{x, y}]}}
              {digits, coords} -> {nums, syms, {digits ++ [char], coords ++ [{x, y}]}}
            end
          true ->
            nums = case cur do
              nil -> nums
              {digits, coords} -> [{digits |> Enum.join() |> String.to_integer(), coords} | nums]
            end
            syms = if char != ".", do: [{{x, y}, char} | syms], else: syms
            {nums, syms, nil}
        end
      end)
    
    # Handle number at end of line
    numbers = case current_num do
      nil -> numbers
      {digits, coords} -> [{digits |> Enum.join() |> String.to_integer(), coords} | numbers]
    end
    
    {numbers, symbols}
  end

  defp adjacent_to_symbol?(coords, symbols) do
    symbol_positions = symbols |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    Enum.any?(coords, fn {x, y} ->
      neighbors(x, y) |> Enum.any?(&MapSet.member?(symbol_positions, &1))
    end)
  end

  defp adjacent_numbers(gear_pos, numbers) do
    {gx, gy} = gear_pos
    gear_neighbors = neighbors(gx, gy) |> MapSet.new()
    
    numbers
    |> Enum.filter(fn {_num, coords} ->
      Enum.any?(coords, &MapSet.member?(gear_neighbors, &1))
    end)
    |> Enum.map(&elem(&1, 0))
  end

  defp neighbors(x, y) do
    for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0}, do: {x + dx, y + dy}
  end
end
