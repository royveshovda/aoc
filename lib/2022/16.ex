import AOC

aoc 2022, 16 do
  @moduledoc """
  Day 16: Proboscidea Volcanium

  Open valves to release max pressure in cave network.
  Part 1: Solo, 30 minutes.
  Part 2: With elephant, 26 minutes each.

  Uses bitmasks for fast disjoint set checking in Part 2.
  """

  @doc """
  Part 1: Max pressure released in 30 minutes.
  """
  def p1(input) do
    {valves, graph} = parse(input)
    distances = floyd_warshall(graph, Map.keys(valves))
    useful_valves = valves |> Enum.filter(fn {_, rate} -> rate > 0 end) |> Map.new()

    # Create valve to bit index mapping
    valve_bits = useful_valves |> Map.keys() |> Enum.with_index() |> Map.new()

    max_pressure(distances, useful_valves, valve_bits, "AA", 30, 0, 0)
  end

  @doc """
  Part 2: Max pressure with elephant helper, 26 minutes each.
  """
  def p2(input) do
    {valves, graph} = parse(input)
    distances = floyd_warshall(graph, Map.keys(valves))
    useful_valves = valves |> Enum.filter(fn {_, rate} -> rate > 0 end) |> Map.new()

    # Create valve to bit index mapping
    valve_bits = useful_valves |> Map.keys() |> Enum.with_index() |> Map.new()

    # Get all possible states and their max pressures (bitmask -> pressure)
    states = all_states(distances, useful_valves, valve_bits, "AA", 26, 0, 0, %{})

    # Sort by pressure descending for early pruning
    states_list = states |> Map.to_list() |> Enum.sort_by(&elem(&1, 1), :desc)

    # Find best combination where human and elephant open disjoint sets
    find_best_pair(states_list, 0)
  end

  defp find_best_pair([], best), do: best
  defp find_best_pair([{mask1, pressure1} | rest], best) do
    # If this alone can't beat current best combined with anything, prune rest
    if pressure1 * 2 < best do
      best
    else
      new_best =
        Enum.reduce_while(rest, best, fn {mask2, pressure2}, acc ->
          # Early termination: if pressure1 + pressure2 can't beat best, stop
          if pressure1 + pressure2 <= acc do
            {:halt, acc}
          else
            if Bitwise.band(mask1, mask2) == 0 do
              {:cont, max(acc, pressure1 + pressure2)}
            else
              {:cont, acc}
            end
          end
        end)
      find_best_pair(rest, new_best)
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, %{}}, fn line, {valves, graph} ->
      [[_, valve, rate, tunnels]] =
        Regex.scan(~r/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/, line)

      neighbors = String.split(tunnels, ", ")
      rate = String.to_integer(rate)

      {Map.put(valves, valve, rate), Map.put(graph, valve, neighbors)}
    end)
  end

  defp floyd_warshall(graph, nodes) do
    # Initialize distances
    initial = for n1 <- nodes, n2 <- nodes, into: %{} do
      cond do
        n1 == n2 -> {{n1, n2}, 0}
        n2 in graph[n1] -> {{n1, n2}, 1}
        true -> {{n1, n2}, 9999}
      end
    end

    # Floyd-Warshall
    Enum.reduce(nodes, initial, fn k, dist ->
      Enum.reduce(nodes, dist, fn i, dist ->
        Enum.reduce(nodes, dist, fn j, dist ->
          new_dist = dist[{i, k}] + dist[{k, j}]
          if new_dist < dist[{i, j}] do
            Map.put(dist, {i, j}, new_dist)
          else
            dist
          end
        end)
      end)
    end)
  end

  defp max_pressure(distances, valves, valve_bits, current, time_left, opened_mask, pressure_so_far) do
    # Try opening each remaining valve
    remaining = valves
      |> Map.keys()
      |> Enum.reject(fn v -> Bitwise.band(opened_mask, Bitwise.bsl(1, valve_bits[v])) != 0 end)

    if remaining == [] or time_left <= 0 do
      pressure_so_far
    else
      Enum.reduce(remaining, pressure_so_far, fn valve, best ->
        travel_time = distances[{current, valve}]
        new_time = time_left - travel_time - 1  # travel + open

        if new_time > 0 do
          bit = valve_bits[valve]
          new_mask = Bitwise.bor(opened_mask, Bitwise.bsl(1, bit))
          pressure_from_this = valves[valve] * new_time
          sub_pressure = max_pressure(distances, valves, valve_bits, valve, new_time, new_mask, pressure_so_far + pressure_from_this)
          max(best, sub_pressure)
        else
          best
        end
      end)
    end
  end

  defp all_states(distances, valves, valve_bits, current, time_left, opened_mask, pressure_so_far, states) do
    # Record this state
    states = Map.update(states, opened_mask, pressure_so_far, &max(&1, pressure_so_far))

    # Try opening each remaining valve
    remaining = valves
      |> Map.keys()
      |> Enum.reject(fn v -> Bitwise.band(opened_mask, Bitwise.bsl(1, valve_bits[v])) != 0 end)

    if remaining == [] or time_left <= 0 do
      states
    else
      Enum.reduce(remaining, states, fn valve, states ->
        travel_time = distances[{current, valve}]
        new_time = time_left - travel_time - 1  # travel + open

        if new_time > 0 do
          bit = valve_bits[valve]
          new_mask = Bitwise.bor(opened_mask, Bitwise.bsl(1, bit))
          pressure_from_this = valves[valve] * new_time
          all_states(distances, valves, valve_bits, valve, new_time, new_mask, pressure_so_far + pressure_from_this, states)
        else
          states
        end
      end)
    end
  end
end
