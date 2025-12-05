import AOC

aoc 2024, 13 do
  @moduledoc """
  https://adventofcode.com/2024/day/13

  Claw Contraption - solve linear system:
  a * ax + b * bx = px
  a * ay + b * by = py
  Cost = 3a + b, find minimum cost or no solution.
  Use Cramer's rule for exact integer solution.
  """

  def p1(input) do
    input
    |> parse()
    |> Enum.map(&solve/1)
    |> Enum.sum()
  end

  def p2(input) do
    offset = 10_000_000_000_000

    input
    |> parse()
    |> Enum.map(fn {{ax, ay}, {bx, by}, {px, py}} ->
      {{ax, ay}, {bx, by}, {px + offset, py + offset}}
    end)
    |> Enum.map(&solve/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_machine/1)
  end

  defp parse_machine(block) do
    nums =
      Regex.scan(~r/\d+/, block)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    [ax, ay, bx, by, px, py] = nums
    {{ax, ay}, {bx, by}, {px, py}}
  end

  # Solve using Cramer's rule
  # ax * a + bx * b = px
  # ay * a + by * b = py
  defp solve({{ax, ay}, {bx, by}, {px, py}}) do
    det = ax * by - ay * bx

    if det == 0 do
      0  # No unique solution
    else
      # a = (px * by - py * bx) / det
      # b = (ax * py - ay * px) / det
      a_num = px * by - py * bx
      b_num = ax * py - ay * px

      if rem(a_num, det) == 0 and rem(b_num, det) == 0 do
        a = div(a_num, det)
        b = div(b_num, det)

        if a >= 0 and b >= 0 do
          3 * a + b
        else
          0
        end
      else
        0
      end
    end
  end
end
