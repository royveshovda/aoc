import AOC

aoc 2024, 14 do
  @moduledoc """
  https://adventofcode.com/2024/day/14
  """

  def p1({input, max_x, max_y}) do
    robots =
      input
      |> String.split("\n")
      |> Enum.map(fn l ->
        [_, px, py, _, vx, vy] = String.split(l, ["=", ",", " "])
        px = String.to_integer(px)
        py = String.to_integer(py)
        vx = String.to_integer(vx)
        vy = String.to_integer(vy)
        {{px, py}, {vx, vy}}
      end)

    moved_robots =
      robots
      |> Enum.map(fn {p, v} -> move_robot(p, v, max_x, max_y, 100) end)

    limit_x = trunc((max_x - 1) / 2)
    limit_y = trunc((max_y - 1) / 2 )
    q1 = moved_robots |> Enum.count(fn {x, y} -> x < limit_x && y < limit_y end)
    q2 = moved_robots |> Enum.count(fn {x, y} -> x > limit_x && y < limit_y end)
    q3 = moved_robots |> Enum.count(fn {x, y} -> x < limit_x && y > limit_y end)
    q4 = moved_robots |> Enum.count(fn {x, y} -> x > limit_x && y > limit_y end)

    q1 * q2 * q3 * q4

  end

  def move_robot({px, py}, {vx, vy}, max_x, max_y, steps) do
    x = positive_mod(px + (steps * vx), max_x)
    y = positive_mod(py + (steps * vy), max_y)
    {x, y}
  end

  def positive_mod(a, b) do
    rem = rem(a, b)
    if rem < 0 do
      rem + b
    else
      rem
    end
  end

  def p2({input, max_x, max_y}) do
    robots =
      input
      |> String.split("\n")
      |> Enum.map(fn l ->
        [_, px, py, _, vx, vy] = String.split(l, ["=", ",", " "])
        px = String.to_integer(px)
        py = String.to_integer(py)
        vx = String.to_integer(vx)
        vy = String.to_integer(vy)
        {{px, py}, {vx, vy}}
      end)

    1..10_000
    |> Enum.reduce_while(nil, fn i, _acc ->
        res =
          move_robots(robots, i, max_x, max_y)
          |> check_robots()

        if res do
          {:halt, i}
        else
          {:cont, nil}
        end
      end)
  end

  def move_robots(robots, steps, max_x, max_y) do
    robots
    |> Enum.map(fn {p, v} -> move_robot(p, v, max_x, max_y, steps) end)
  end

  def check_robots(robots) do
    length(robots) == Enum.uniq(robots) |> length()
  end
end
