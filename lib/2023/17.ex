import AOC

aoc 2023, 17 do
  @moduledoc """
  https://adventofcode.com/2023/day/17

  A* pathfinding with line-based moves.
  """

  @doc """
      iex> p1(example_string())
      102

      iex> p1(input_string())
      724
  """
  def p1(input) do
    input
    |> parse_input()
    |> find_path(&p1_line/2)
  end

  @doc """
      iex> p2(example_string())
      94

      iex> p2(input_string())
      877
  """
  def p2(input) do
    input
    |> parse_input()
    |> find_path(&p2_line/2)
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> Utils.Grid.input_to_map_with_bounds(&String.to_integer/1)
  end

  defp find_path({grid, {_..max_x//_, _..max_y//_} = bounds}, line_fun) do
    [{0, 0, :v}, {0, 0, :h}]
    |> Enum.map(&{manhattan(&1, {max_x, max_y}), &1})
    |> Enum.reduce({Heap.min(), %{}}, fn {h, option}, {queue, costs} ->
      {Heap.push(queue, {h, option}), Map.put(costs, option, 0)}
    end)
    |> a_star(line_fun, {max_x, max_y}, grid, bounds)
  end

  defp a_star({queue, costs}, line_fun, goal, grid, bounds) do
    {{_, current = {x, y, _}}, queue} = Heap.split(queue)
    current_cost = costs[current]

    if {x, y} == goal do
      current_cost
    else
      current
      |> options(bounds, line_fun)
      |> Enum.reduce({queue, costs}, fn option, {q, c} ->
        score = current_cost + cost(current, option, grid)
        if not Map.has_key?(c, option) or score < c[option] do
          h = score + manhattan(option, goal)
          {Heap.push(q, {h, option}), Map.put(c, option, score)}
        else
          {q, c}
        end
      end)
      |> a_star(line_fun, goal, grid, bounds)
    end
  end

  defp options({x, y, :v}, {x_range, _}, line), do: line.(x, x_range) |> Enum.map(&{&1, y, :h})
  defp options({x, y, :h}, {_, y_range}, line), do: line.(y, y_range) |> Enum.map(&{x, &1, :v})

  defp p1_line(i, min..max//_), do: for(j <- (i - 3)..(i + 3), j != i, j >= min, j <= max, do: j)

  defp p2_line(i, min..max//_) do
    left = for j <- (i - 10)..(i - 4), j >= min, do: j
    right = for j <- (i + 4)..(i + 10), j <= max, do: j
    left ++ right
  end

  defp cost({x_from, y_from, _}, {x_to, y_to, _}, grid) do
    for x <- min(x_from, x_to)..max(x_from, x_to),
        y <- min(y_from, y_to)..max(y_from, y_to),
        not (x == x_from and y == y_from),
        reduce: 0 do
      sum -> sum + grid[{x, y}]
    end
  end

  defp manhattan({x, y, _}, {goal_x, goal_y}), do: abs(goal_x - x) + abs(goal_y - y)
end
