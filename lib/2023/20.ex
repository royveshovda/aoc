import AOC

aoc 2023, 20 do
  @moduledoc """
  https://adventofcode.com/2023/day/20
  """

  @doc """
      iex> p1(example_string())
      32000000

      iex> p1(example_string_p1_2())
      11687500

      iex> p1(input_string())
      747304011
  """
  def p1(input) do
    initial_config =
      input
      |> parse_input()

    presses =
      for _i <- 1..1000 do
        {[{"broadcaster", :low, :button}], {0, 1}}
      end

    {{high, low}, _} =
      Enum.reduce(presses, {{0, 0}, initial_config}, fn {press, {h,l}}, {{high, low}, c} ->
        {{new_high, new_low}, new_c} = pulse(c, press, {h, l})
        {{new_high + high, new_low + low}, new_c}
      end)

    high * low
  end

  def example_string_p1_2() do
    """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """
  end

  def pulse(config, [], pulses), do: {pulses, config}

  def pulse(config, [{current_module_label, pulse_type, from} | rest], {high_pulses, low_pulses}) do
    module = config[current_module_label]
    case module do
      nil ->
        pulse(config, rest, {high_pulses, low_pulses})
      _ ->
        {new_config, new_emits, {add_high, add_low}} = pulse_module(config, module, pulse_type, from)
        pulse(new_config, rest ++ new_emits, {high_pulses + add_high, low_pulses + add_low})
    end
  end

  def pulse_module(config, module, pulse_type, from) do
    case module.type do
      :flipflop ->
        case pulse_type do
          :high -> {config, [], {0, 0}}
          :low ->
            case module.state do
              :off ->
                dest = for x <- module.destinations, do: {x, :high, module.label}
                {Map.put(config, module.label, %{module | state: :on}), dest, {length(dest), 0}}
              :on ->
                dest = for x <- module.destinations, do: {x, :low, module.label}
                {Map.put(config, module.label, %{module | state: :off}), dest, {0, length(dest)}}
            end
        end
      :conjunction ->
        new_state = Map.put(module.state, from, pulse_type)
        case Enum.all?(new_state, fn {_, v} -> v == :high end) do
          true ->
            dest = for x <- module.destinations, do: {x, :low, module.label}
            {Map.put(config, module.label, %{module | state: new_state}), dest, {0, length(dest)}}
          false ->
            dest = for x <- module.destinations, do: {x, :high, module.label}
            {Map.put(config, module.label, %{module | state: new_state}), dest, {length(dest), 0}}
        end
      :broadcaster ->
        dest = for x <- module.destinations, do: {x, pulse_type, module.label}
        pulse_count =
          case pulse_type do
            :high ->
              {length(dest), 0}
            :low ->
              {0, length(dest)}
          end
        {config, dest, pulse_count}
    end
  end

  @doc """
      iex> p2(input_string())
      220366255099387
  """
  def p2(input) do
    initial_config =
      input
      |> parse_input()

    presses =
      for i <- 1..5000 do
        {[{"broadcaster", :low, :button}], i}
      end

    # Search for cyclic patterns for "bm", "cl", "tn" and "dr"
    # Can search for each time each of them gets a low signal
    # Stop when all of them have been low at least 2 times each
    # Calculate using LCM of the cycle lengths
    # Consider if offset is needed

    # TODO: Find these from config
    pulsars = %{"bm" => [], "cl" => [], "tn" => [], "dr" => []}

    {cycles, _c} =
      Enum.reduce(presses, {pulsars, initial_config}, fn {press, i}, {p, c} ->
        {new_pulsars, new_c} = pulse_p2(c, press, p, i)
        {new_pulsars, new_c}
      end)

    cycles
    |> Enum.map(fn {k, v} -> Enum.min(v) end)
    |> Enum.reduce(&lcm/2)
  end

  def lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  def pulse_p2(config, [], pulsars, _i), do: {pulsars, config}

  def pulse_p2(config, [{current_module_label, pulse_type, from} | rest], pulsars, i) do
    module = config[current_module_label]
    case module do
      nil ->
        pulse_p2(config, rest, pulsars, i)
      _ ->
        {new_config, new_emits, _} = pulse_module(config, module, pulse_type, from)
        ps = Map.keys(pulsars)
        candidates =
          new_emits
          |> Enum.filter(fn {_, type, _} ->
            type == :low
          end)
          |> Enum.filter(fn {l, _, _} ->
            l in ps
          end)

        new_pulsars =
          case length(candidates) > 0 do
            true ->
              Enum.reduce(candidates, pulsars, fn {l, t, _}, acc ->
                Map.update(acc, l, [t], fn x -> [i | x] end)
              end)
            false ->
              pulsars
          end

        pulse_p2(new_config, rest ++ new_emits, new_pulsars, i)
    end
  end

  def parse_input(input) do
    config =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Enum.map(fn {label, {type, destinations, initial_state}} ->
        {label, %{label: label, type: type, destinations: destinations, state: initial_state}}
      end)
      |> Enum.into(%{})

    populate_connections(config)
  end

  def populate_connections(config) do
    config
    |> Enum.map(fn {label, module} ->
      case module.type do

        :conjunction ->
          from =
            config
            |> Enum.filter(fn {_, m} -> label in m.destinations end)
            |> Enum.map(fn {l, _} -> {l, :low} end)
            |> Enum.into(%{})
          {label, %{module | state: from}}
        _ ->
          {label, module}
      end
    end)
    |> Enum.into(%{})
  end

  def parse_line(line) do
    [ins, out] = line |> String.split("->", trim: true)
    {label, type, initial_state} = parse_type(ins |> String.trim())
    destinations = parse_destinations(out)
    {label, {type, destinations, initial_state}}
  end

  def parse_type("broadcaster") do
    {"broadcaster", :broadcaster, :all}
  end

  def parse_type(ins) do
    t = String.at(ins, 0)
    label = String.slice(ins, 1..-1)
    {type, initial_state} =
      case t do
        "%" -> {:flipflop, :off}
        "&" -> {:conjunction, :low}
      end

    {label, type, initial_state}
  end

  def parse_destinations(out) do
    out
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
