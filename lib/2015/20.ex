import AOC

aoc 2015, 20 do
  @moduledoc """
  https://adventofcode.com/2015/day/20

  Day 20: Infinite Elves and Infinite Houses

  Find the lowest house number that receives at least the target number of presents.
  Each elf delivers to houses that are multiples of their number.
  """

  def p1(input) do
    target = String.trim(input) |> String.to_integer()
    find_house_with_presents(target, 10, :infinity)
  end

  def p2(input) do
    target = String.trim(input) |> String.to_integer()
    # Part 2: Each elf delivers to only 50 houses, 11 presents per house
    find_house_with_presents(target, 11, 50)
  end

  defp find_house_with_presents(target, presents_per_elf, max_houses) do
    # Start searching from a reasonable lower bound
    # Theoretical minimum is target / (presents_per_elf * average_divisors)
    start = div(target, presents_per_elf * 60)

    # Use a sieve-like approach for efficiency
    # Estimate upper bound generously
    limit = div(target, presents_per_elf) + 10000

    houses = :ets.new(:houses, [:set, :private])

    try do
      # For each elf, add presents to houses they visit
      1..limit
      |> Enum.each(fn elf ->
        deliver_presents(houses, elf, limit, presents_per_elf, max_houses)
      end)

      # Find first house with enough presents
      start..limit
      |> Enum.find(fn house ->
        presents = case :ets.lookup(houses, house) do
          [{^house, count}] -> count
          [] -> 0
        end
        presents >= target
      end)
    after
      :ets.delete(houses)
    end
  end

  defp deliver_presents(houses, elf, limit, presents_per_elf, max_houses) do
    # Calculate how many houses this elf visits
    houses_to_visit = if max_houses == :infinity do
      div(limit, elf)
    else
      min(max_houses, div(limit, elf))
    end

    # Visit each house that's a multiple of elf number
    1..houses_to_visit
    |> Enum.each(fn visit_num ->
      house = elf * visit_num
      if house <= limit do
        presents = elf * presents_per_elf
        :ets.update_counter(houses, house, presents, {house, 0})
      end
    end)
  end
end
