import AOC

aoc 2019, 14 do
  @moduledoc """
  https://adventofcode.com/2019/day/14
  Space Stoichiometry - chemical reaction calculations
  """

  @trillion 1_000_000_000_000

  def p1(input) do
    reactions = parse(input)
    ore_needed(reactions, 1)
  end

  def p2(input) do
    reactions = parse(input)
    ore_for_one = ore_needed(reactions, 1)

    # Binary search for max FUEL with 1 trillion ORE
    # Lower bound: at least (1 trillion / ore_for_one) FUEL
    # Upper bound: could be higher due to leftover efficiency
    min_fuel = div(@trillion, ore_for_one)
    max_fuel = min_fuel * 2

    binary_search(reactions, min_fuel, max_fuel)
  end

  defp binary_search(reactions, low, high) when low >= high - 1 do
    if ore_needed(reactions, high) <= @trillion, do: high, else: low
  end

  defp binary_search(reactions, low, high) do
    mid = div(low + high, 2)
    ore = ore_needed(reactions, mid)

    if ore <= @trillion do
      binary_search(reactions, mid, high)
    else
      binary_search(reactions, low, mid)
    end
  end

  defp ore_needed(reactions, fuel_amount) do
    # Work backwards from FUEL, tracking what we need and what we have leftover
    needs = %{"FUEL" => fuel_amount}
    surplus = %{}

    calculate_ore(reactions, needs, surplus)
  end

  defp calculate_ore(reactions, needs, surplus) do
    # Find a chemical we need that's not ORE
    case Enum.find(needs, fn {chem, amt} -> chem != "ORE" and amt > 0 end) do
      nil ->
        # Only ORE left (or nothing)
        Map.get(needs, "ORE", 0)

      {chemical, amount_needed} ->
        # Use surplus first
        available = Map.get(surplus, chemical, 0)
        {use_from_surplus, still_needed} =
          if available >= amount_needed do
            {amount_needed, 0}
          else
            {available, amount_needed - available}
          end

        surplus = Map.update(surplus, chemical, 0, &(&1 - use_from_surplus))
        needs = Map.delete(needs, chemical)

        if still_needed > 0 do
          # Need to produce more of this chemical
          {output_amount, inputs} = Map.fetch!(reactions, chemical)

          # How many times do we need to run the reaction?
          times = div(still_needed + output_amount - 1, output_amount)
          produced = times * output_amount
          leftover = produced - still_needed

          # Add leftover to surplus
          surplus = Map.update(surplus, chemical, leftover, &(&1 + leftover))

          # Add inputs to needs
          needs =
            Enum.reduce(inputs, needs, fn {input_amt, input_chem}, acc ->
              Map.update(acc, input_chem, input_amt * times, &(&1 + input_amt * times))
            end)

          calculate_ore(reactions, needs, surplus)
        else
          calculate_ore(reactions, needs, surplus)
        end
    end
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_reaction/1)
    |> Map.new()
  end

  defp parse_reaction(line) do
    [inputs_str, output_str] = String.split(line, " => ")

    {output_amount, output_chem} = parse_chemical(output_str)

    inputs =
      inputs_str
      |> String.split(", ")
      |> Enum.map(&parse_chemical/1)

    # Map: output_chemical => {output_amount, [{input_amount, input_chemical}, ...]}
    {output_chem, {output_amount, inputs}}
  end

  defp parse_chemical(str) do
    [amount, chem] = String.split(str, " ")
    {String.to_integer(amount), chem}
  end
end
