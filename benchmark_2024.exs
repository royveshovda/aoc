# Benchmark script to compare new vs original 2024 implementations
# Run with: mix run benchmark_2024.exs

defmodule Benchmark2024 do
  @original_dir "backup_2024_original"
  @new_dir "lib/2024"

  def run do
    IO.puts("\n" <> String.duplicate("=", 90))
    IO.puts("Benchmarking 2024 Solutions: NEW vs ORIGINAL")
    IO.puts(String.duplicate("=", 90))
    IO.puts("")
    IO.puts(String.pad_trailing("Day", 5) <>
            String.pad_leading("New P1", 12) <>
            String.pad_leading("Orig P1", 12) <>
            String.pad_leading("New P2", 12) <>
            String.pad_leading("Orig P2", 12) <>
            String.pad_leading("Winner", 10))
    IO.puts(String.duplicate("-", 90))

    results =
      for day <- 1..25 do
        input_file = "input/2024_#{day}.txt"

        if File.exists?(input_file) do
          input = File.read!(input_file)

          # Handle special cases where input is a tuple
          {p1_input, p2_input} =
            case day do
              14 -> {{input, 101, 103}, {input, 101, 103}}
              18 -> {{input, 1024, 70}, {input, 1024, 70}}
              _ -> {input, input}
            end

          # Benchmark NEW implementation
          {new_p1, new_p2} = benchmark_implementation(@new_dir, day, p1_input, p2_input)

          # Benchmark ORIGINAL implementation
          {orig_p1, orig_p2} = benchmark_implementation(@original_dir, day, p1_input, p2_input)

          # Determine winner
          new_total = (new_p1 || 999999) + (new_p2 || 999999)
          orig_total = (orig_p1 || 999999) + (orig_p2 || 999999)
          winner = cond do
            new_total < orig_total * 0.9 -> "NEW"
            orig_total < new_total * 0.9 -> "ORIG"
            true -> "~TIE"
          end

          IO.puts(
            String.pad_trailing("#{day}", 5) <>
            String.pad_leading(format_time(new_p1), 12) <>
            String.pad_leading(format_time(orig_p1), 12) <>
            String.pad_leading(format_time(new_p2), 12) <>
            String.pad_leading(format_time(orig_p2), 12) <>
            String.pad_leading(winner, 10)
          )

          {day, new_p1, new_p2, orig_p1, orig_p2, winner}
        else
          IO.puts("Day #{String.pad_leading(to_string(day), 2)}: SKIPPED")
          {day, nil, nil, nil, nil, "SKIP"}
        end
      end

    # Summary
    new_p1_total = results |> Enum.map(&elem(&1, 1)) |> Enum.reject(&is_nil/1) |> Enum.sum()
    new_p2_total = results |> Enum.map(&elem(&1, 2)) |> Enum.reject(&is_nil/1) |> Enum.sum()
    orig_p1_total = results |> Enum.map(&elem(&1, 3)) |> Enum.reject(&is_nil/1) |> Enum.sum()
    orig_p2_total = results |> Enum.map(&elem(&1, 4)) |> Enum.reject(&is_nil/1) |> Enum.sum()

    new_wins = results |> Enum.count(fn r -> elem(r, 5) == "NEW" end)
    orig_wins = results |> Enum.count(fn r -> elem(r, 5) == "ORIG" end)
    ties = results |> Enum.count(fn r -> elem(r, 5) == "~TIE" end)

    IO.puts(String.duplicate("-", 90))
    IO.puts(
      String.pad_trailing("TOTAL", 5) <>
      String.pad_leading(format_time(new_p1_total), 12) <>
      String.pad_leading(format_time(orig_p1_total), 12) <>
      String.pad_leading(format_time(new_p2_total), 12) <>
      String.pad_leading(format_time(orig_p2_total), 12)
    )
    IO.puts("")
    IO.puts("NEW total:  #{format_time(new_p1_total + new_p2_total)}")
    IO.puts("ORIG total: #{format_time(orig_p1_total + orig_p2_total)}")
    IO.puts("")
    IO.puts("Wins: NEW=#{new_wins}, ORIG=#{orig_wins}, TIE=#{ties}")

    results
  end

  defp benchmark_implementation(dir, day, p1_input, p2_input) do
    file = Path.join(dir, "#{day}.ex")

    if File.exists?(file) do
      # Load the module from file
      modules = Code.compile_file(file)
      # Find the main module (Y2024.Dxx)
      module_name = :"Elixir.Y2024.D#{day}"
      {module, _} = Enum.find(modules, fn {m, _} -> m == module_name end) || {nil, nil}

      if module do
        # Benchmark P1
        p1_ms =
          try do
            {time, _} = :timer.tc(fn -> apply(module, :p1, [p1_input]) end)
            time / 1000
          rescue
            _ -> nil
          end

        # Benchmark P2
        p2_ms =
          try do
            {time, _} = :timer.tc(fn -> apply(module, :p2, [p2_input]) end)
            time / 1000
          rescue
            _ -> nil
          end

        {p1_ms, p2_ms}
      else
        {nil, nil}
      end
    else
      {nil, nil}
    end
  end

  defp format_time(nil), do: "N/A"
  defp format_time(ms) when ms < 1, do: "#{Float.round(ms * 1000, 1)}µs"
  defp format_time(ms) when ms < 1000, do: "#{Float.round(ms, 1)}ms"
  defp format_time(ms), do: "#{Float.round(ms / 1000, 2)}s"
end

Benchmark2024.run()
