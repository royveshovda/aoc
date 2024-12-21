import AOC

aoc 2024, 20 do
  @moduledoc """
  https://adventofcode.com/2024/day/20
  """

  def p1(input) do
    lines =
      input
      |> String.split("\n", trim: true)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, x}, acc2 ->
          Map.put(acc2, {x, y}, char)
        end)
      end)

    start =
      grid
      |> Enum.find(fn {_k, v} -> v == "S" end)
      |> elem(0)

    finish =
      grid
      |> Enum.find(fn {_k, v} -> v == "E" end)
      |> elem(0)

    dirs = [{0,1}, {0,-1}, {1,0}, {-1,0}]

    # Compute costs from `finish` to all cells
    costs = BFS.all_costs(grid, finish, dirs)

    # Now run the cheat BFS
    part1 = BFS.cheat_bfs(grid, costs, start, 2, 100, dirs)
    length(part1)
  end

  def p2(input) do
    lines =
      input
      |> String.split("\n", trim: true)

    grid =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, x}, acc2 ->
          Map.put(acc2, {x, y}, char)
        end)
      end)

    start =
      grid
      |> Enum.find(fn {_k, v} -> v == "S" end)
      |> elem(0)

    finish =
      grid
      |> Enum.find(fn {_k, v} -> v == "E" end)
      |> elem(0)

    dirs = [{0,1}, {0,-1}, {1,0}, {-1,0}]

    # Compute costs from `finish` to all cells
    costs = BFS.all_costs(grid, finish, dirs)

    part2 = BFS.cheat_bfs(grid, costs, start, 20, 100, dirs)
    length(part2)
  end
end

defmodule BFS do
  @moduledoc """
  Provides a BFS-like search with an optional 'cheat' mechanic,
  translated from the Python version.
  """

  @doc """
  Translated `cheat_bfs/5` from Python.

  * `grid` is a map of `{x, y} => character`
  * `costs` is a map of `{x, y} => cost_from_end`
  * `start` is the starting coordinate `{x, y}`
  * `maxcount` is the maximum "cheat" count
  * `target` is the numerical threshold for `costs[start] - v >= target`
  * `dirs` is a list of directions (e.g., `[{0,1}, {0,-1}, {1,0}, {-1,0}]`)
  """
  def cheat_bfs(grid, costs, start, maxcount, target, dirs) do
    # We'll use Erlang's :queue for BFS
    queue = :queue.from_list([{start, false, maxcount, 0}])
    seen = MapSet.new()
    saved = %{}

    # Recur until the queue is empty
    final_saved =
      do_cheat_bfs(
        queue,
        seen,
        saved,
        grid,
        costs,
        start,
        target,
        dirs
      )

    # Return those locations (with their cheat-flag) whose saved cost
    # is such that costs[start] - cost >= target
    final_saved
    |> Enum.filter(fn {_k, v} -> Map.get(costs, start, 0) - v >= target end)
    |> Enum.map(fn {k, _v} -> k end)
  end

  # Private recursive function that processes the queue
  defp do_cheat_bfs(queue, seen, saved, grid, costs, start, target, dirs) do
    case :queue.out(queue) do
      {{:value, {loc, cheat, count, dist}}, rest_queue} ->
        cond do
          # if we've already seen {loc, cheat} or the count is < 0, skip
          MapSet.member?(seen, {loc, cheat}) or count < 0 ->
            do_cheat_bfs(rest_queue, seen, saved, grid, costs, start, target, dirs)

          cheat ->
            # Mark {loc, cheat} as seen
            seen = MapSet.put(seen, {loc, cheat})

            # If not a wall and (cost at loc + dist) < cost at start, update saved
            saved =
              if Map.get(grid, loc) != "#" and
                 (Map.get(costs, loc, 0) + dist < Map.get(costs, start, 0)) do
                Map.put(saved, {loc, cheat}, Map.get(costs, loc, 0) + dist)
              else
                saved
              end

            # Enqueue neighbors as (new, cheat, count-1, dist+1) if new is in grid
            new_queue =
              Enum.reduce(dirs, rest_queue, fn {dx, dy}, acc_queue ->
                new_loc = {elem(loc, 0) + dx, elem(loc, 1) + dy}

                if Map.has_key?(grid, new_loc) do
                  :queue.in({new_loc, cheat, count - 1, dist + 1}, acc_queue)
                else
                  acc_queue
                end
              end)

            do_cheat_bfs(new_queue, seen, saved, grid, costs, start, target, dirs)

          true ->
            # cheat = false branch
            seen = MapSet.put(seen, {loc, cheat})

            # 1) Enqueue neighbors as (new, loc, count-1, dist+1)
            #    if new is in grid
            queue_after_phase1 =
              Enum.reduce(dirs, rest_queue, fn {dx, dy}, acc_queue ->
                new_loc = {elem(loc, 0) + dx, elem(loc, 1) + dy}

                if Map.has_key?(grid, new_loc) do
                  :queue.in({new_loc, loc, count - 1, dist + 1}, acc_queue)
                else
                  acc_queue
                end
              end)

            # 2) Enqueue neighbors as (new, cheat, count, dist+1)
            #    if new is in grid and not a wall
            new_queue =
              Enum.reduce(dirs, queue_after_phase1, fn {dx, dy}, acc_queue ->
                new_loc = {elem(loc, 0) + dx, elem(loc, 1) + dy}

                if Map.has_key?(grid, new_loc) and Map.get(grid, new_loc) != "#" do
                  :queue.in({new_loc, cheat, count, dist + 1}, acc_queue)
                else
                  acc_queue
                end
              end)

            do_cheat_bfs(new_queue, seen, saved, grid, costs, start, target, dirs)
        end

      # No more items in the queue, return whatever's in `saved`
      {:empty, _} ->
        saved
    end
  end

  def all_costs(grid, finish, dirs \\ [{0,1}, {0,-1}, {1,0}, {-1,0}]) do
    queue = :queue.from_list([{finish, 0}])
    visited = MapSet.new([finish])
    costs = %{}

    do_all_costs_bfs(grid, finish, dirs, queue, visited, costs)
  end

  defp do_all_costs_bfs(grid, finish, dirs, queue, visited, costs) do
    case :queue.out(queue) do
      {{:value, {loc, dist}}, queue_rest} ->
        # record the cost/distance for this location
        costs = Map.put(costs, loc, dist)

        # explore neighbors
        {queue_updated, visited_updated} =
          Enum.reduce(dirs, {queue_rest, visited}, fn {dx, dy}, {q, v} ->
            new_loc = {elem(loc, 0) + dx, elem(loc, 1) + dy}

            # Check if new_loc is accessible, not a wall, and not visited yet
            if Map.has_key?(grid, new_loc) and Map.get(grid, new_loc) != "#" and not MapSet.member?(v, new_loc) do
              { :queue.in({new_loc, dist + 1}, q), MapSet.put(v, new_loc) }
            else
              {q, v}
            end
          end)

        do_all_costs_bfs(grid, finish, dirs, queue_updated, visited_updated, costs)

      {:empty, _} ->
        # No more cells to process
        costs
    end
  end
end
