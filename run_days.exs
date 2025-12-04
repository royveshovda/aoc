# Universal AOC solution runner
# Usage: mix run run_days.exs [year] [start_day] [end_day]
# Example: mix run run_days.exs 2017 11 20
# Example: mix run run_days.exs 2024 1 25

{year, start_day, end_day} = case System.argv() do
  [y, s, e] -> {String.to_integer(y), String.to_integer(s), String.to_integer(e)}
  [] -> {2015, 1, 25}  # Default to 2015 days 1-25
  _ ->
    IO.puts("Usage: mix run run_days.exs [year] [start_day] [end_day]")
    System.halt(1)
end

results =
  start_day..end_day
  |> Enum.map(fn day ->
    module = Module.concat([String.to_atom("Elixir.Y#{year}"), String.to_atom("D#{day}")])
    input_file = "input/#{year}_#{day}.txt"

    if File.exists?(input_file) do
      input = File.read!(input_file)
      IO.write("Day #{day}...")

      try do
        p1 = module.p1(input)

        # Try to call p2, but handle if it doesn't exist (day 25 only has part 1)
        p2 = try do
          module.p2(input)
        rescue
          UndefinedFunctionError -> :no_part2
        end

        IO.puts(" ✓")
        {:ok, day, p1, p2}
      rescue
        e ->
          IO.puts(" ✗ (#{inspect(e.__struct__)})")
          {:error, day, e}
      end
    else
      IO.puts("Day #{day}... ✗ (input file not found)")
      {:error, day, :no_input}
    end
  end)

successful = Enum.filter(results, &match?({:ok, _, _, _}, &1))
failed = Enum.filter(results, &match?({:error, _, _}, &1))

if length(successful) > 0 do
  IO.puts("\n=== #{year} Days #{start_day}-#{end_day} Results ===\n")
  IO.puts("| Day | Part 1           | Part 2           |")
  IO.puts("|-----|------------------|------------------|")

  Enum.each(successful, fn {:ok, day, p1, p2} ->
    p2_display = cond do
      p2 == :no_part2 -> "⭐"
      is_binary(p2) and String.contains?(p2, "No Part 2") -> "⭐"
      true -> "#{p2}"
    end
    IO.puts("| #{String.pad_leading("#{day}", 3)} | #{String.pad_trailing("#{p1}", 16)} | #{String.pad_trailing(p2_display, 16)} |")
  end)
end

if length(failed) > 0 do
  IO.puts("\n=== Failed ===")
  Enum.each(failed, fn {:error, day, reason} ->
    IO.puts("Day #{day}: #{inspect(reason)}")
  end)
end

IO.puts("\nCompleted: #{length(successful)}/#{end_day - start_day + 1}")
