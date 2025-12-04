import AOC

aoc 2015, 12 do
  @moduledoc """
  https://adventofcode.com/2015/day/12

  Day 12: JSAbacusFramework.io
  Sum all numbers in a JSON document.
  """

  @doc """
  Part 1: Sum all numbers in the JSON document.

  Examples:
  - [1,2,3] → 6
  - {"a":2,"b":4} → 6
  - [[[3]]] → 3
  - {"a":{"b":4},"c":-1} → 3
  - {"a":[-1,1]} → 0
  - [-1,{"a":1}] → 0
  - [] → 0
  - {} → 0

      iex> p1("[1,2,3]")
      6

      iex> p1(~s({"a":2,"b":4}))
      6

      iex> p1("[[[3]]]")
      3

      iex> p1(~s({"a":{"b":4},"c":-1}))
      3
  """
  def p1(input) do
    input
    |> String.trim()
    |> Jason.decode!()
    |> sum_numbers()
  end

  @doc """
  Part 2: Sum all numbers, but ignore any object (and its children)
  that has a property with value "red".

  Examples:
  - [1,2,3] → 6
  - [1,{"c":"red","b":2},3] → 4 (middle object ignored)
  - {"d":"red","e":[1,2,3,4],"f":5} → 0 (entire object ignored)
  - [1,"red",5] → 6 (arrays are never ignored)
  """
  def p2(input) do
    input
    |> String.trim()
    |> Jason.decode!()
    |> sum_numbers_skip_red()
  end

  # Part 1: Sum all numbers recursively
  defp sum_numbers(data) when is_number(data), do: data
  defp sum_numbers(data) when is_list(data) do
    Enum.reduce(data, 0, fn item, acc -> acc + sum_numbers(item) end)
  end
  defp sum_numbers(data) when is_map(data) do
    data
    |> Map.values()
    |> Enum.reduce(0, fn item, acc -> acc + sum_numbers(item) end)
  end
  defp sum_numbers(_), do: 0

  # Part 2: Sum numbers but skip objects containing "red" as a value
  defp sum_numbers_skip_red(data) when is_number(data), do: data
  defp sum_numbers_skip_red(data) when is_list(data) do
    Enum.reduce(data, 0, fn item, acc -> acc + sum_numbers_skip_red(item) end)
  end
  defp sum_numbers_skip_red(data) when is_map(data) do
    # Check if any value is "red"
    if Enum.any?(Map.values(data), &(&1 == "red")) do
      0
    else
      data
      |> Map.values()
      |> Enum.reduce(0, fn item, acc -> acc + sum_numbers_skip_red(item) end)
    end
  end
  defp sum_numbers_skip_red(_), do: 0
end
