# Benchmark script for 2023 AoC solutions
# Run with: mix run benchmark_2023.exs

defmodule Benchmark2023 do
  @warmup_runs 1
  @timed_runs 3

  def run do
    IO.puts("\n" <> String.duplicate("=", 70))
    IO.puts("2023 Advent of Code - Solution Timing")
    IO.puts(String.duplicate("=", 70))

    results = for day <- 1..25 do
      run_day(day)
    end

    print_summary(results)
  end

  defp run_day(day) do
    input = File.read!("input/2023_#{day}.txt")
    module = String.to_atom("Elixir.Y2023.D#{day}")

    {p1, t1} = time_function(fn ->
      case day do
        21 -> apply(module, :p1, [input, 64])
        24 -> apply(module, :p1, [input, 200_000_000_000_000, 400_000_000_000_000])
        _ -> apply(module, :p1, [input])
      end
    end)

    {p2, t2} = time_function(fn -> apply(module, :p2, [input]) end)

    total = (t1 || 0) + (t2 || 0)

    IO.puts("Day #{String.pad_leading("#{day}", 2)}: P1=#{format_time(t1)} (#{p1}), P2=#{format_time(t2)} (#{p2}), Total=#{format_time(total)}")

    %{day: day, p1_time: t1, p2_time: t2, total: total, p1: p1, p2: p2}
  end

  defp time_function(fun) do
    # Warmup
    for _ <- 1..@warmup_runs, do: fun.()

    # Timed runs
    times = for _ <- 1..@timed_runs do
      {time, result} = :timer.tc(fun)
      {time / 1000, result}  # Convert to ms
    end

    avg_time = times |> Enum.map(&elem(&1, 0)) |> Enum.sum() |> Kernel./(@timed_runs)
    result = times |> List.first() |> elem(1)

    {result, avg_time}
  rescue
    e ->
      IO.puts("  Error: #{inspect(e)}")
      {nil, nil}
  end

  defp format_time(nil), do: "N/A"
  defp format_time(ms) when ms < 1, do: "#{Float.round(ms * 1000, 1)}μs"
  defp format_time(ms) when ms < 1000, do: "#{Float.round(ms, 1)}ms"
  defp format_time(ms), do: "#{Float.round(ms / 1000, 2)}s"

  defp print_summary(results) do
    IO.puts("\n" <> String.duplicate("=", 70))
    IO.puts("SUMMARY")
    IO.puts(String.duplicate("=", 70))

    total_time = results |> Enum.map(&(&1.total || 0)) |> Enum.sum()
    IO.puts("\nTotal time: #{format_time(total_time)}")

    slowest = results |> Enum.sort_by(&(-&1.total)) |> Enum.take(5)
    IO.puts("\nSlowest days:")
    for r <- slowest do
      IO.puts("  Day #{r.day}: #{format_time(r.total)}")
    end
  end
end

Benchmark2023.run()
