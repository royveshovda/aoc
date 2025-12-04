import AOC

aoc 2016, 11 do
  @moduledoc """
  https://adventofcode.com/2016/day/11
  """

  @doc """
      iex> p1(example_string(0))
  """
  def p1(input) do
    state = parse(input)
    solve(state)
  end

  @doc """
      iex> p2(example_string(0))
  """
  def p2(input) do
    state = parse(input)
    # Add elerium and dilithium to floor 0
    new_floor0 = state.floors[0] ++ [:elerium_gen, :elerium_chip, :dilithium_gen, :dilithium_chip]
    new_state = %{state | floors: Map.put(state.floors, 0, new_floor0)}
    solve(new_state)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)
    floors =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, floor} ->
        items = parse_floor(line)
        {floor, items}
      end)
      |> Map.new()

    %{elevator: 0, floors: floors}
  end

  defp parse_floor(line) do
    generators = Regex.scan(~r/(\w+) generator/, line)
                |> Enum.map(fn [_, element] -> String.to_atom(element <> "_gen") end)

    chips = Regex.scan(~r/(\w+)-compatible microchip/, line)
           |> Enum.map(fn [_, element] -> String.to_atom(element <> "_chip") end)

    generators ++ chips
  end

  defp solve(initial_state) do
    queue = :queue.from_list([{initial_state, 0}])
    visited = MapSet.new([normalize(initial_state)])
    bfs(queue, visited)
  end

  defp bfs(queue, visited) do
    case :queue.out(queue) do
      {{:value, {state, steps}}, queue} ->
        if goal?(state) do
          steps
        else
          next_states = get_next_states(state)
                       |> Enum.reject(fn s -> MapSet.member?(visited, normalize(s)) end)

          new_queue = Enum.reduce(next_states, queue, fn s, q -> :queue.in({s, steps + 1}, q) end)
          new_visited = Enum.reduce(next_states, visited, fn s, v -> MapSet.put(v, normalize(s)) end)

          bfs(new_queue, new_visited)
        end
      {:empty, _} -> nil
    end
  end

  defp goal?(state) do
    Enum.all?(0..2, fn floor -> Enum.empty?(state.floors[floor]) end)
  end

  defp get_next_states(state) do
    current_floor = state.elevator
    current_items = state.floors[current_floor]

    # Generate all possible moves (1 or 2 items)
    moves =
      (for item <- current_items, do: [item]) ++
      (for i <- current_items, j <- current_items, i < j, do: [i, j])

    # Try moving up and down
    directions = []
    directions = if current_floor < 3, do: [current_floor + 1 | directions], else: directions
    directions = if current_floor > 0, do: [current_floor - 1 | directions], else: directions

    for items <- moves,
        new_floor <- directions do
      new_current = current_items -- items
      new_target = state.floors[new_floor] ++ items

      if valid_floor?(new_current) and valid_floor?(new_target) do
        %{
          elevator: new_floor,
          floors: state.floors
                  |> Map.put(current_floor, new_current)
                  |> Map.put(new_floor, new_target)
        }
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  defp valid_floor?(items) do
    chips = items |> Enum.filter(&String.ends_with?(Atom.to_string(&1), "_chip"))
    generators = items |> Enum.filter(&String.ends_with?(Atom.to_string(&1), "_gen"))

    # If no generators, any chips are safe
    # If generators exist, each chip must have its matching generator
    Enum.empty?(generators) or
    Enum.all?(chips, fn chip ->
      element = chip |> Atom.to_string() |> String.replace("_chip", "")
      String.to_atom(element <> "_gen") in generators
    end)
  end

  # Normalize state for visited tracking - only care about pairs of items, not specific elements
  defp normalize(state) do
    pairs =
      state.floors
      |> Enum.flat_map(fn {floor, items} ->
        items |> Enum.map(fn item ->
          element = item |> Atom.to_string() |> String.split("_") |> hd()
          type = if String.ends_with?(Atom.to_string(item), "_gen"), do: :gen, else: :chip
          {element, type, floor}
        end)
      end)
      |> Enum.group_by(fn {element, _, _} -> element end)
      |> Enum.map(fn {_element, items} ->
        gen_floor = items |> Enum.find(fn {_, type, _} -> type == :gen end) |> then(fn {_, _, f} -> f end)
        chip_floor = items |> Enum.find(fn {_, type, _} -> type == :chip end) |> then(fn {_, _, f} -> f end)
        {gen_floor, chip_floor}
      end)
      |> Enum.sort()

    {state.elevator, pairs}
  end
end
