import AOC

aoc 2023, 20 do
  @moduledoc """
  https://adventofcode.com/2023/day/20

  Pulse propagation simulation with flip-flops and conjunctions.
  """

  @doc """
      iex> p1(example_string())
      32000000

      iex> p1(input_string())
      747304011
  """
  def p1(input) do
    {modules, connections} = parse(input)
    state = init_state(modules, connections)

    {low, high, _} = Enum.reduce(1..1000, {0, 0, state}, fn _, {low, high, state} ->
      {dl, dh, new_state} = press_button(modules, connections, state)
      {low + dl, high + dh, new_state}
    end)

    low * high
  end

  @doc """
      iex> p2(input_string())
      220366255099387
  """
  def p2(input) do
    {modules, connections} = parse(input)
    state = init_state(modules, connections)

    # Find the conjunction that feeds into rx
    # Then find cycle length for each input to that conjunction
    rx_feeder = connections |> Enum.find(fn {_, dests} -> "rx" in dests end) |> elem(0)
    feeder_inputs = modules
                    |> Enum.filter(fn {_, {_, dests}} -> rx_feeder in dests end)
                    |> Enum.map(&elem(&1, 0))

    # Find cycle length for each input - when it sends high to rx_feeder
    find_cycles(modules, connections, state, feeder_inputs, %{}, 1)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [left, right] = String.split(line, " -> ")
      destinations = String.split(right, ", ")

      {name, type} = case left do
        "broadcaster" -> {"broadcaster", :broadcaster}
        "%" <> name -> {name, :flipflop}
        "&" <> name -> {name, :conjunction}
      end

      {name, {type, destinations}}
    end)
    |> then(fn parsed ->
      modules = Map.new(parsed)
      connections = parsed |> Enum.map(fn {name, {_, dests}} -> {name, dests} end) |> Map.new()
      {modules, connections}
    end)
  end

  defp init_state(modules, connections) do
    # Flip-flops start off, conjunctions remember low for all inputs
    Enum.reduce(modules, %{}, fn {name, {type, _}}, state ->
      case type do
        :flipflop -> Map.put(state, name, :off)
        :conjunction ->
          # Find all inputs to this conjunction
          inputs = connections
                   |> Enum.filter(fn {_, dests} -> name in dests end)
                   |> Enum.map(&elem(&1, 0))
          memory = Map.new(inputs, fn inp -> {inp, :low} end)
          Map.put(state, name, memory)
        :broadcaster -> state
      end
    end)
  end

  defp press_button(modules, connections, state) do
    # Queue: {from, to, pulse_type}
    queue = :queue.from_list([{"button", "broadcaster", :low}])
    process_pulses(queue, modules, connections, state, 0, 0)
  end

  defp process_pulses(queue, modules, connections, state, low, high) do
    case :queue.out(queue) do
      {:empty, _} -> {low, high, state}

      {{:value, {from, to, pulse}}, queue} ->
        {low, high} = if pulse == :low, do: {low + 1, high}, else: {low, high + 1}

        case Map.get(modules, to) do
          nil ->
            # Unknown module (like rx), ignore
            process_pulses(queue, modules, connections, state, low, high)

          {:broadcaster, dests} ->
            queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, pulse}, q) end)
            process_pulses(queue, modules, connections, state, low, high)

          {:flipflop, dests} ->
            if pulse == :high do
              process_pulses(queue, modules, connections, state, low, high)
            else
              new_state = if state[to] == :off, do: :on, else: :off
              out_pulse = if new_state == :on, do: :high, else: :low
              state = Map.put(state, to, new_state)
              queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, out_pulse}, q) end)
              process_pulses(queue, modules, connections, state, low, high)
            end

          {:conjunction, dests} ->
            memory = Map.put(state[to], from, pulse)
            state = Map.put(state, to, memory)
            out_pulse = if Enum.all?(Map.values(memory), &(&1 == :high)), do: :low, else: :high
            queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, out_pulse}, q) end)
            process_pulses(queue, modules, connections, state, low, high)
        end
    end
  end

  defp find_cycles(_modules, _connections, _state, [], cycles, _n) do
    cycles |> Map.values() |> Enum.reduce(1, &lcm/2)
  end

  defp find_cycles(modules, connections, state, waiting, cycles, n) do
    {state, sent_high} = press_button_watch(modules, connections, state, waiting)

    # Check which of our targets sent high this press
    {new_cycles, still_waiting} = Enum.reduce(waiting, {cycles, []}, fn target, {cyc, wait} ->
      if target in sent_high do
        {Map.put(cyc, target, n), wait}
      else
        {cyc, [target | wait]}
      end
    end)

    find_cycles(modules, connections, state, still_waiting, new_cycles, n + 1)
  end

  defp press_button_watch(modules, connections, state, watch_list) do
    queue = :queue.from_list([{"button", "broadcaster", :low}])
    process_pulses_watch(queue, modules, connections, state, watch_list, MapSet.new())
  end

  defp process_pulses_watch(queue, modules, connections, state, watch_list, sent_high) do
    case :queue.out(queue) do
      {:empty, _} -> {state, sent_high}

      {{:value, {from, to, pulse}}, queue} ->
        # Track if watched modules send high
        sent_high = if from in watch_list and pulse == :high, do: MapSet.put(sent_high, from), else: sent_high

        case Map.get(modules, to) do
          nil ->
            process_pulses_watch(queue, modules, connections, state, watch_list, sent_high)

          {:broadcaster, dests} ->
            queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, pulse}, q) end)
            process_pulses_watch(queue, modules, connections, state, watch_list, sent_high)

          {:flipflop, dests} ->
            if pulse == :high do
              process_pulses_watch(queue, modules, connections, state, watch_list, sent_high)
            else
              new_state = if state[to] == :off, do: :on, else: :off
              out_pulse = if new_state == :on, do: :high, else: :low
              state = Map.put(state, to, new_state)
              queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, out_pulse}, q) end)
              process_pulses_watch(queue, modules, connections, state, watch_list, sent_high)
            end

          {:conjunction, dests} ->
            memory = Map.put(state[to], from, pulse)
            state = Map.put(state, to, memory)
            out_pulse = if Enum.all?(Map.values(memory), &(&1 == :high)), do: :low, else: :high
            queue = Enum.reduce(dests, queue, fn dest, q -> :queue.in({to, dest, out_pulse}, q) end)
            process_pulses_watch(queue, modules, connections, state, watch_list, sent_high)
        end
    end
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b), do: div(a * b, gcd(a, b))
end
