input = File.read!("input/2017_21_example_0.txt")
rules_input = """
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
"""

rules = rules_input
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  [pattern, result] = String.split(line, " => ")
  pattern_grid = String.split(pattern, "/")
  result_grid = String.split(result, "/")
  IO.inspect({pattern_grid, result_grid}, label: "Rule")
  {pattern_grid, result_grid}
end)

start = [".#.", "..#", "###"]
IO.inspect(start, label: "Start")
IO.inspect(length(start), label: "Start size")
