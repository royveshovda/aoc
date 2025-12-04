#!/usr/bin/env elixir

# Load the application
Mix.install([])
Code.require_file("lib/2025/1.ex")

example_input = File.read!("input/2025_1_example_0.txt")
actual_input = File.read!("input/2025_1.txt")

IO.puts("Example result: #{AOC.Y2025.D1.p1(example_input)}")
IO.puts("Actual result: #{AOC.Y2025.D1.p1(actual_input)}")
