import AOC

aoc 2015, 14 do
  @moduledoc """
  https://adventofcode.com/2015/day/14

  Day 14: Reindeer Olympics
  Simulate reindeer race with flying/resting cycles.
  """

  @doc """
  Part 1: After 2503 seconds, what distance has the winning reindeer traveled?

  Reindeer alternate between flying (at speed) and resting (stationary).
  """
  def p1(input, time \\ 2503) do
    input
    |> parse_reindeer()
    |> Enum.map(fn reindeer -> calculate_distance(reindeer, time) end)
    |> Enum.max()
  end

  @doc """
  Part 2: Award points to the leader(s) at each second.
  After 2503 seconds, how many points does the winning reindeer have?
  """
  def p2(input, time \\ 2503) do
    reindeer_list = parse_reindeer(input)

    # Simulate second by second, awarding points to leaders
    1..time
    |> Enum.reduce(%{}, fn second, points ->
      # Calculate distance for each reindeer at this second
      distances =
        reindeer_list
        |> Enum.map(fn reindeer ->
          {reindeer.name, calculate_distance(reindeer, second)}
        end)
        |> Map.new()

      # Find max distance
      max_distance = distances |> Map.values() |> Enum.max()

      # Award points to all reindeer at max distance
      distances
      |> Enum.reduce(points, fn {name, distance}, acc ->
        if distance == max_distance do
          Map.update(acc, name, 1, &(&1 + 1))
        else
          acc
        end
      end)
    end)
    |> Map.values()
    |> Enum.max()
  end

  defp parse_reindeer(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Example: "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds."
    regex = ~r/^(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds\.$/
    [name, speed, fly_time, rest_time] = Regex.run(regex, line, capture: :all_but_first)

    %{
      name: name,
      speed: String.to_integer(speed),
      fly_time: String.to_integer(fly_time),
      rest_time: String.to_integer(rest_time)
    }
  end

  defp calculate_distance(reindeer, time) do
    cycle_time = reindeer.fly_time + reindeer.rest_time

    # Complete cycles
    full_cycles = div(time, cycle_time)
    remaining_time = rem(time, cycle_time)

    # Distance from complete cycles
    distance_from_cycles = full_cycles * reindeer.fly_time * reindeer.speed

    # Distance from remaining time (may be partial flying)
    remaining_fly_time = min(remaining_time, reindeer.fly_time)
    distance_from_remaining = remaining_fly_time * reindeer.speed

    distance_from_cycles + distance_from_remaining
  end
end
