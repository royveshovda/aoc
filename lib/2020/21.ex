import AOC

aoc 2020, 21 do
  @moduledoc """
  https://adventofcode.com/2020/day/21

  Allergen Assessment - Match allergens to ingredients.

  ## Examples

      iex> example = "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)\\ntrh fvjkl sbzzf mxmxvkd (contains dairy)\\nsqjhc fvjkl (contains soy)\\nsqjhc mxmxvkd sbzzf (contains fish)"
      iex> Y2020.D21.p1(example)
      5

      iex> example = "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)\\ntrh fvjkl sbzzf mxmxvkd (contains dairy)\\nsqjhc fvjkl (contains soy)\\nsqjhc mxmxvkd sbzzf (contains fish)"
      iex> Y2020.D21.p2(example)
      "mxmxvkd,sqjhc,fvjkl"
  """

  def p1(input) do
    foods = parse(input)

    # Find possible allergen -> ingredient mappings
    possible = find_possible_mappings(foods)

    # Find ingredients that definitely have allergens
    allergen_ingredients =
      possible
      |> Map.values()
      |> Enum.reduce(&MapSet.union/2)

    # Count appearances of non-allergen ingredients
    all_ingredients = Enum.flat_map(foods, fn {ingredients, _} -> ingredients end)

    all_ingredients
    |> Enum.count(&(!MapSet.member?(allergen_ingredients, &1)))
  end

  def p2(input) do
    foods = parse(input)
    possible = find_possible_mappings(foods)

    # Eliminate to find unique assignments
    assignments = eliminate(possible, %{})

    # Sort by allergen name and join ingredient names
    assignments
    |> Enum.sort_by(fn {allergen, _ingredient} -> allergen end)
    |> Enum.map(fn {_allergen, ingredient} -> ingredient end)
    |> Enum.join(",")
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [ingredients_part, allergens_part] = String.split(line, " (contains ")
    ingredients = String.split(ingredients_part, " ") |> MapSet.new()
    allergens = allergens_part |> String.trim_trailing(")") |> String.split(", ")
    {ingredients, allergens}
  end

  defp find_possible_mappings(foods) do
    # For each allergen, find intersection of ingredients in all foods containing it
    foods
    |> Enum.flat_map(fn {ingredients, allergens} ->
      Enum.map(allergens, &{&1, ingredients})
    end)
    |> Enum.group_by(fn {allergen, _} -> allergen end, fn {_, ingredients} -> ingredients end)
    |> Map.new(fn {allergen, ingredients_lists} ->
      {allergen, Enum.reduce(ingredients_lists, &MapSet.intersection/2)}
    end)
  end

  defp eliminate(possible, assignments) when map_size(possible) == 0, do: assignments

  defp eliminate(possible, assignments) do
    # Find an allergen with only one possible ingredient
    {allergen, ingredients} =
      Enum.find(possible, fn {_allergen, ingredients} -> MapSet.size(ingredients) == 1 end)

    [ingredient] = MapSet.to_list(ingredients)

    # Remove this allergen and this ingredient from all others
    new_possible =
      possible
      |> Map.delete(allergen)
      |> Map.new(fn {a, i} -> {a, MapSet.delete(i, ingredient)} end)

    eliminate(new_possible, Map.put(assignments, allergen, ingredient))
  end
end
