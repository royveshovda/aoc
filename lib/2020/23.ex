import AOC

aoc 2020, 23 do
  @moduledoc """
  https://adventofcode.com/2020/day/23

  Crab Cups - Circle manipulation (linked list for Part 2).
  Uses an array where index = cup label, value = next cup label.

  ## Examples

      iex> Y2020.D23.p1("389125467")
      "67384529"

      iex> Y2020.D23.p2("389125467")
      149245887792
  """

  def p1(input) do
    cups = parse(input)
    max_cup = length(cups)

    # Build linked list: next[cup] = next_cup
    next = build_linked_list(cups, max_cup)
    current = hd(cups)

    # Play 100 moves
    next = play_moves(next, current, max_cup, 100)

    # Read labels after cup 1
    read_after_one(next, max_cup - 1)
  end

  def p2(input) do
    cups = parse(input)
    max_cup = 1_000_000
    moves = 10_000_000

    # Build linked list with cups extended to 1 million
    next = build_linked_list(cups, max_cup)
    current = hd(cups)

    # Play 10 million moves
    next = play_moves(next, current, max_cup, moves)

    # Get the two cups after cup 1
    first = :array.get(1, next)
    second = :array.get(first, next)

    first * second
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp build_linked_list(cups, max_cup) do
    # Array where index = cup, value = next cup
    # Index 0 is unused (cups are 1-indexed)
    next = :array.new(max_cup + 1, default: 0)

    # Link the initial cups
    next =
      cups
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(next, fn [a, b], acc ->
        :array.set(a, b, acc)
      end)

    # If we need more cups (Part 2), extend the circle
    last_initial = List.last(cups)
    first_initial = hd(cups)

    if max_cup > length(cups) do
      # Link last initial cup to first extended cup
      next = :array.set(last_initial, length(cups) + 1, next)

      # Link extended cups sequentially
      next =
        (length(cups) + 1)..(max_cup - 1)
        |> Enum.reduce(next, fn i, acc ->
          :array.set(i, i + 1, acc)
        end)

      # Link last cup back to first
      :array.set(max_cup, first_initial, next)
    else
      # Just link last to first for Part 1
      :array.set(last_initial, first_initial, next)
    end
  end

  defp play_moves(next, _current, _max_cup, 0), do: next

  defp play_moves(next, current, max_cup, moves_left) do
    # Pick up 3 cups after current
    pick1 = :array.get(current, next)
    pick2 = :array.get(pick1, next)
    pick3 = :array.get(pick2, next)
    after_picked = :array.get(pick3, next)

    # Find destination cup (current - 1, wrapping, skipping picked)
    dest = find_destination(current, max_cup, pick1, pick2, pick3)

    # Rewire: current -> after_picked
    next = :array.set(current, after_picked, next)

    # Insert picked cups after destination
    after_dest = :array.get(dest, next)
    next = :array.set(dest, pick1, next)
    next = :array.set(pick3, after_dest, next)

    # Move to next current
    new_current = :array.get(current, next)

    play_moves(next, new_current, max_cup, moves_left - 1)
  end

  defp find_destination(current, max_cup, pick1, pick2, pick3) do
    dest = if current == 1, do: max_cup, else: current - 1

    if dest == pick1 or dest == pick2 or dest == pick3 do
      find_destination(dest, max_cup, pick1, pick2, pick3)
    else
      dest
    end
  end

  defp read_after_one(next, count) do
    read_after_one(next, 1, count, [])
  end

  defp read_after_one(_next, _current, 0, acc) do
    acc |> Enum.reverse() |> Enum.join()
  end

  defp read_after_one(next, current, count, acc) do
    next_cup = :array.get(current, next)
    read_after_one(next, next_cup, count - 1, [next_cup | acc])
  end
end
