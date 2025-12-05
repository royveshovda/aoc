import AOC

aoc 2020, 5 do
  @moduledoc """
  https://adventofcode.com/2020/day/5

  Binary Boarding - Decode boarding passes (binary space partitioning).
  """

  @doc """
  Find highest seat ID. F/L = 0, B/R = 1 in binary.

  ## Examples

      iex> seat_id("FBFBBFFRLR")
      357

      iex> seat_id("BFFFBBFRRR")
      567

      iex> seat_id("FFFBBBFRRR")
      119

      iex> seat_id("BBFFBBFRLL")
      820
  """
  def p1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&seat_id/1)
    |> Enum.max()
  end

  @doc """
  Find your seat - the gap in the list of seat IDs.
  """
  def p2(input) do
    seats =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&seat_id/1)
      |> MapSet.new()

    min_seat = Enum.min(seats)
    max_seat = Enum.max(seats)

    min_seat..max_seat
    |> Enum.find(fn id -> not MapSet.member?(seats, id) end)
  end

  def seat_id(pass) do
    pass
    |> String.replace(~r/[FL]/, "0")
    |> String.replace(~r/[BR]/, "1")
    |> String.to_integer(2)
  end
end
