import AOC

aoc 2015, 15 do
  @moduledoc """
  https://adventofcode.com/2015/day/15

  Day 15: Science for Hungry People
  Find the optimal cookie recipe with exactly 100 teaspoons of ingredients.
  """

  @doc """
  Part 1: Find the highest scoring cookie (score = product of positive property sums).

  Example: 44 Butterscotch + 56 Cinnamon = 62842880

      iex> p1(example_string(0))
      62842880
  """
  def p1(input) do
    ingredients = parse_ingredients(input)

    # Generate all combinations that sum to 100
    generate_combinations(length(ingredients), 100)
    |> Enum.map(fn amounts -> calculate_score(ingredients, amounts) end)
    |> Enum.max()
  end

  @doc """
  Part 2: Find the highest scoring cookie with exactly 500 calories.
  """
  def p2(input) do
    ingredients = parse_ingredients(input)

    # Generate all combinations that sum to 100
    generate_combinations(length(ingredients), 100)
    |> Enum.filter(fn amounts -> calculate_calories(ingredients, amounts) == 500 end)
    |> Enum.map(fn amounts -> calculate_score(ingredients, amounts) end)
    |> Enum.max()
  end

  defp parse_ingredients(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Example: "Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8"
    regex = ~r/^(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)$/
    [_name, capacity, durability, flavor, texture, calories] =
      Regex.run(regex, line, capture: :all_but_first)

    %{
      capacity: String.to_integer(capacity),
      durability: String.to_integer(durability),
      flavor: String.to_integer(flavor),
      texture: String.to_integer(texture),
      calories: String.to_integer(calories)
    }
  end

  defp calculate_score(ingredients, amounts) do
    properties = [:capacity, :durability, :flavor, :texture]

    properties
    |> Enum.map(fn prop ->
      sum = ingredients
      |> Enum.zip(amounts)
      |> Enum.map(fn {ingredient, amount} -> Map.get(ingredient, prop) * amount end)
      |> Enum.sum()

      max(0, sum)
    end)
    |> Enum.reduce(1, &*/2)
  end

  defp calculate_calories(ingredients, amounts) do
    ingredients
    |> Enum.zip(amounts)
    |> Enum.map(fn {ingredient, amount} -> ingredient.calories * amount end)
    |> Enum.sum()
  end

  # Generate all combinations of n numbers that sum to total
  defp generate_combinations(1, total), do: [[total]]
  defp generate_combinations(n, total) do
    for i <- 0..total,
        rest <- generate_combinations(n - 1, total - i),
        do: [i | rest]
  end
end
