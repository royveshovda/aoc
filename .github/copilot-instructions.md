# Copilot instructions (AoC Elixir repo)

For detailed conventions and workflows, start with:
- `AGENTS.md` (project + workflow conventions)
- `toolbox/README.md` (algorithm/pattern index)

## Repo essentials
- Each AoC day is defined via `advent_of_code_utils` macros.
  - Solution source: `lib/<year>/<day>.ex` (example: `lib/2024/1.ex`)
  - Compiled module name: `Y<year>.D<day>` (example: `Y2024.D1`)
- Required public API per day: `p1/1` and `p2/1` that accept the raw input string.
- Inputs live in `input/<year>_<day>.txt`.

## Tests + running
- Tests live in `test/<year>/<day>_test.exs` and typically use `aoc_test YYYY, DD, async: true do`.
- Prefer `input_string()` for real puzzle input inside tests.
- Quick run commands:
  - `mix test test/2024/1_test.exs`
  - `mix test --exclude skip`
  - `mix run run_days.exs 2024 1 25`
  - `iex -S mix` then call `Y2024.D1.p1(input)`.

## Environment gotcha
- `config/config.exs` loads `AOC_TOKEN` from a local `.env` file and raises if missing.
  - Expect `AOC_TOKEN` to live only in `.env` (not exported globally in your shell).
