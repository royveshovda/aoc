import AOC

aoc 2023, 17 do
  @moduledoc """
  https://adventofcode.com/2023/day/17

  Crucible pathfinding - A* with line-based moves.
  State is {x, y, orientation} where orientation is :h or :v.
  Each move jumps 1-3 (P1) or 4-10 (P2) cells perpendicular to current orientation.
  """

  @doc """
      iex> p1(example_string())
      102

      iex> p1(input_string())
      724
  """
  def p1(input) do
    input
    |> parse()
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
    |> parse()
    |> find_path(&p2_line/2)
  end

  defp parse(input) do
    Utils.Grid.input_to_map_with_bounds(input, &String.to_integer/1)
  end

  defp find_path({_, {_..max_x//_, _..max_y//_}} = grid, line_fun) do
    [{0, 0, :v}, {0, 0, :h}]
    |> Enum.map(&{manhattan(&1, {max_x, max_y}), &1})
    |> Enum.reduce({Heap.min(), %{}}, fn el = {_, option}, {queue, cheapest_paths} ->
      {Heap.push(queue, el), Map.put(cheapest_paths, option, 0)}
    end)
    |> a_star(line_fun, {max_x, max_y}, grid)
  end

  defp a_star({queue, cheapest_paths}, line_fun, goal, {grid, bounds}) do
    {{_, current = {x, y, _}}, queue} = Heap.split(queue)
    current_score = cheapest_paths[current]

    if {x, y} == goal do
      current_score
    else
      current
      |> options(bounds, line_fun)
      |> Enum.reduce({queue, cheapest_paths}, fn option, {queue, cheapest_paths} ->
        score = current_score + cost(current, option, grid)
        if not Map.has_key?(cheapest_paths, option) or score < cheapest_paths[option] do
          heuristic = score + manhattan(option, goal)
          {Heap.push(queue, {heuristic, option}), Map.put(cheapest_paths, option, score)}
        else
          {queue, cheapest_paths}
        end
      end)
      |> a_star(line_fun, goal, {grid, bounds})
    end
  end

  defp options({x, y, :v}, {bounds, _}, line), do: x |> line.(bounds) |> Enum.map(&{&1, y, :h})
  defp options({x, y, :h}, {_, bounds}, line), do: y |> line.(bounds) |> Enum.map(&{x, &1, :v})

  defp p1_line(i, min..max//_), do: for(j <- i - 3..i + 3, j != i, j >= min, j <= max, do: j)

  defp p2_line(i, min..max//_) do
    Enum.concat(
      for(j <- i + 4..i + 10, j <= max, do: j),
      for(j <- i - 10..i - 4, j >= min, do: j)
    )
  end

  defp cost({x_from, y_from, _}, {x_to, y_to, _}, grid) do
    for x <- x_from..x_to, y <- y_from..y_to, not (x == x_from and y == y_from), reduce: 0 do
      sum -> sum + grid[{x, y}]
    end
  end

  defp manhattan({x, y, _}, {goal_x, goal_y}), do: abs(goal_x - x) + abs(goal_y - y)
end
