import AOC

aoc 2020, 13 do
  @moduledoc """
  https://adventofcode.com/2020/day/13

  Shuttle Search - Bus schedules (Chinese Remainder Theorem for Part 2).

  ## Examples

      iex> example = "939\\n7,13,x,x,59,x,31,19"
      iex> Y2020.D13.p1(example)
      295

      iex> example = "939\\n7,13,x,x,59,x,31,19"
      iex> Y2020.D13.p2(example)
      1068781

      iex> Y2020.D13.p2("0\\n17,x,13,19")
      3417

      iex> Y2020.D13.p2("0\\n67,7,59,61")
      754018

      iex> Y2020.D13.p2("0\\n67,x,7,59,61")
      779210

      iex> Y2020.D13.p2("0\\n67,7,x,59,61")
      1261476

      iex> Y2020.D13.p2("0\\n1789,37,47,1889")
      1202161486
  """

  def p1(input) do
    {timestamp, buses} = parse(input)

    # Find the bus with minimum wait time
    {bus_id, wait_time} =
      buses
      |> Enum.reject(fn {_, id} -> id == :x end)
      |> Enum.map(fn {_, id} ->
        # Next departure is ceil(timestamp / id) * id
        next_departure = div(timestamp + id - 1, id) * id
        wait = next_departure - timestamp
        {id, wait}
      end)
      |> Enum.min_by(fn {_, wait} -> wait end)

    bus_id * wait_time
  end

  def p2(input) do
    {_timestamp, buses} = parse(input)

    # Build list of {offset, bus_id} for non-x buses
    # We need: (t + offset) ≡ 0 (mod bus_id)
    # Which means: t ≡ -offset (mod bus_id)
    # Or equivalently: t ≡ (bus_id - offset % bus_id) % bus_id (mod bus_id)
    constraints =
      buses
      |> Enum.reject(fn {_, id} -> id == :x end)
      |> Enum.map(fn {offset, bus_id} ->
        remainder = rem(bus_id - rem(offset, bus_id), bus_id)
        {remainder, bus_id}
      end)

    # Use sieving approach (similar to CRT)
    # Start with first constraint
    [{r0, m0} | rest] = constraints

    {result, _} =
      Enum.reduce(rest, {r0, m0}, fn {ri, mi}, {current, step} ->
        # Find t such that t ≡ current (mod step) and t ≡ ri (mod mi)
        t = find_matching(current, step, ri, mi)
        # New step is LCM of previous step and mi (since all bus IDs are prime, it's step * mi)
        {t, step * mi}
      end)

    result
  end

  defp parse(input) do
    [timestamp_str, buses_str] = String.split(input, "\n", trim: true)
    timestamp = String.to_integer(timestamp_str)

    buses =
      buses_str
      |> String.split(",")
      |> Enum.with_index()
      |> Enum.map(fn
        {"x", idx} -> {idx, :x}
        {id, idx} -> {idx, String.to_integer(id)}
      end)

    {timestamp, buses}
  end

  # Find smallest t where t ≡ current (mod step) and t ≡ ri (mod mi)
  defp find_matching(current, step, ri, mi) do
    if rem(current, mi) == ri do
      current
    else
      find_matching(current + step, step, ri, mi)
    end
  end
end
