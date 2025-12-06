import AOC

aoc 2021, 23 do
  @moduledoc """
  Day 23: Amphipod

  Move amphipods to destination rooms with minimum energy.
  A=1, B=10, C=100, D=1000 energy per step.
  Rules:
  - Amphipods won't stop in front of rooms (positions 2,4,6,8 in hallway)
  - Once in hallway, can only move into its destination room
  - Won't enter destination room if other types are there
  """

  @doc """
  Part 1: Organize amphipods with 2 per room.
  """
  def p1(input) do
    initial_state = parse(input)
    solve(initial_state, 2)
  end

  @doc """
  Part 2: Unfold to 4 per room with extra amphipods:
  Between rows 1 and 2, insert: D,C,B,A and D,B,A,C
  """
  def p2(input) do
    initial_state = parse_part2(input)
    solve(initial_state, 4)
  end

  @energy %{?A => 1, ?B => 10, ?C => 100, ?D => 1000}
  @room_x %{?A => 2, ?B => 4, ?C => 6, ?D => 8}

  defp solve(initial_state, room_size) do
    # Dijkstra's algorithm
    heap = Heap.new(fn {a, _}, {b, _} -> a < b end)
    heap = Heap.push(heap, {0, initial_state})
    dijkstra(heap, MapSet.new(), room_size)
  end

  defp dijkstra(heap, visited, room_size) do
    {{energy, state}, heap} = {Heap.root(heap), Heap.pop(heap)}

    cond do
      done?(state, room_size) ->
        energy

      MapSet.member?(visited, state) ->
        dijkstra(heap, visited, room_size)

      true ->
        visited = MapSet.put(visited, state)
        moves = possible_moves(state, room_size)

        heap =
          Enum.reduce(moves, heap, fn {new_state, move_energy}, h ->
            Heap.push(h, {energy + move_energy, new_state})
          end)

        dijkstra(heap, visited, room_size)
    end
  end

  defp done?(state, room_size) do
    Enum.all?([?A, ?B, ?C, ?D], fn type ->
      room_x = Map.get(@room_x, type)

      Enum.all?(1..room_size, fn depth ->
        Map.get(state, {:room, room_x, depth}) == type
      end)
    end)
  end

  defp possible_moves(state, room_size) do
    hallway_to_room_moves(state, room_size) ++ room_to_hallway_moves(state, room_size)
  end

  # Move from hallway to destination room
  defp hallway_to_room_moves(state, room_size) do
    hallway_positions = [0, 1, 3, 5, 7, 9, 10]

    Enum.flat_map(hallway_positions, fn x ->
      case Map.get(state, {:hallway, x}) do
        nil ->
          []

        type ->
          dest_x = Map.get(@room_x, type)

          if can_enter_room?(state, type, room_size) and hallway_clear?(state, x, dest_x) do
            depth = find_room_depth(state, dest_x, room_size)
            steps = abs(x - dest_x) + depth
            energy = steps * Map.get(@energy, type)

            new_state =
              state
              |> Map.delete({:hallway, x})
              |> Map.put({:room, dest_x, depth}, type)

            [{new_state, energy}]
          else
            []
          end
      end
    end)
  end

  # Move from room to hallway
  defp room_to_hallway_moves(state, room_size) do
    room_xs = [2, 4, 6, 8]
    hallway_targets = [0, 1, 3, 5, 7, 9, 10]

    Enum.flat_map(room_xs, fn room_x ->
      case top_of_room(state, room_x, room_size) do
        nil ->
          []

        {depth, type} ->
          # Don't move if already in correct room and not blocking others
          if should_leave_room?(state, room_x, type, depth, room_size) do
            Enum.flat_map(hallway_targets, fn target_x ->
              if hallway_clear?(state, room_x, target_x) and
                   Map.get(state, {:hallway, target_x}) == nil do
                steps = depth + abs(room_x - target_x)
                energy = steps * Map.get(@energy, type)

                new_state =
                  state
                  |> Map.delete({:room, room_x, depth})
                  |> Map.put({:hallway, target_x}, type)

                [{new_state, energy}]
              else
                []
              end
            end)
          else
            []
          end
      end
    end)
  end

  defp can_enter_room?(state, type, room_size) do
    room_x = Map.get(@room_x, type)

    Enum.all?(1..room_size, fn depth ->
      case Map.get(state, {:room, room_x, depth}) do
        nil -> true
        ^type -> true
        _ -> false
      end
    end)
  end

  defp find_room_depth(state, room_x, room_size) do
    # Find deepest empty slot
    room_size..1
    |> Enum.find(fn depth -> Map.get(state, {:room, room_x, depth}) == nil end)
  end

  defp top_of_room(state, room_x, room_size) do
    1..room_size
    |> Enum.find_value(fn depth ->
      case Map.get(state, {:room, room_x, depth}) do
        nil -> nil
        type -> {depth, type}
      end
    end)
  end

  defp should_leave_room?(state, room_x, type, _depth, room_size) do
    correct_room_x = Map.get(@room_x, type)

    if room_x != correct_room_x do
      true
    else
      # Check if blocking wrong types below
      Enum.any?(1..room_size, fn d ->
        case Map.get(state, {:room, room_x, d}) do
          nil -> false
          ^type -> false
          _ -> true
        end
      end)
    end
  end

  defp hallway_clear?(state, from_x, to_x) do
    range = if from_x < to_x, do: (from_x + 1)..to_x, else: to_x..(from_x - 1)

    Enum.all?(range, fn x ->
      Map.get(state, {:hallway, x}) == nil
    end)
  end

  defp parse(input) do
    lines = String.split(input, "\n", trim: true)

    # Line 2 has top row of rooms, line 3 has bottom row
    # Rooms are at columns 3, 5, 7, 9 (0-indexed)
    top_row = Enum.at(lines, 2) |> String.to_charlist()
    bottom_row = Enum.at(lines, 3) |> String.to_charlist()

    %{
      {:room, 2, 1} => Enum.at(top_row, 3),
      {:room, 2, 2} => Enum.at(bottom_row, 3),
      {:room, 4, 1} => Enum.at(top_row, 5),
      {:room, 4, 2} => Enum.at(bottom_row, 5),
      {:room, 6, 1} => Enum.at(top_row, 7),
      {:room, 6, 2} => Enum.at(bottom_row, 7),
      {:room, 8, 1} => Enum.at(top_row, 9),
      {:room, 8, 2} => Enum.at(bottom_row, 9)
    }
  end

  defp parse_part2(input) do
    lines = String.split(input, "\n", trim: true)

    top_row = Enum.at(lines, 2) |> String.to_charlist()
    bottom_row = Enum.at(lines, 3) |> String.to_charlist()

    # Insert rows:
    # Row 2: D C B A
    # Row 3: D B A C
    %{
      {:room, 2, 1} => Enum.at(top_row, 3),
      {:room, 2, 2} => ?D,
      {:room, 2, 3} => ?D,
      {:room, 2, 4} => Enum.at(bottom_row, 3),
      {:room, 4, 1} => Enum.at(top_row, 5),
      {:room, 4, 2} => ?C,
      {:room, 4, 3} => ?B,
      {:room, 4, 4} => Enum.at(bottom_row, 5),
      {:room, 6, 1} => Enum.at(top_row, 7),
      {:room, 6, 2} => ?B,
      {:room, 6, 3} => ?A,
      {:room, 6, 4} => Enum.at(bottom_row, 7),
      {:room, 8, 1} => Enum.at(top_row, 9),
      {:room, 8, 2} => ?A,
      {:room, 8, 3} => ?C,
      {:room, 8, 4} => Enum.at(bottom_row, 9)
    }
  end
end
