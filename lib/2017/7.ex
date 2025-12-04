import AOC

aoc 2017, 7 do
  @moduledoc """
  https://adventofcode.com/2017/day/7
  """

  def p1(input) do
    programs = parse(input)
    all_names = Map.keys(programs)
    children = programs |> Map.values() |> Enum.flat_map(fn {_, _, c} -> c end) |> MapSet.new()

    all_names
    |> Enum.find(fn name -> not MapSet.member?(children, name) end)
  end

  def p2(input) do
    programs = parse(input)
    root = p1(input)

    case find_imbalance(root, programs) do
      {:imbalanced, _name, needed_weight} -> needed_weight
      _ -> nil
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [name, rest] = String.split(line, " (")
      [weight_str, children_str] = String.split(rest, ")")
      weight = String.to_integer(weight_str)

      children =
        if String.contains?(children_str, "->") do
          children_str
          |> String.split(" -> ")
          |> List.last()
          |> String.split(", ")
        else
          []
        end

      {name, {name, weight, children}}
    end)
  end

  defp find_imbalance(name, programs) do
    {_name, weight, children} = Map.get(programs, name)

    if children == [] do
      {:balanced, weight}
    else
      child_results = Enum.map(children, &find_imbalance(&1, programs))

      case Enum.find(child_results, fn r -> match?({:imbalanced, _, _}, r) end) do
        {:imbalanced, _, _} = result -> result
        nil ->
          weights = Enum.map(child_results, fn {:balanced, w} -> w end)

          if length(Enum.uniq(weights)) == 1 do
            {:balanced, weight + Enum.sum(weights)}
          else
            freq = Enum.frequencies(weights)
            [{wrong_weight, 1}, {correct_weight, _}] = Enum.sort_by(freq, fn {_, c} -> c end)
            diff = correct_weight - wrong_weight

            wrong_idx = Enum.find_index(weights, &(&1 == wrong_weight))
            wrong_child = Enum.at(children, wrong_idx)
            {_, child_weight, _} = Map.get(programs, wrong_child)

            {:imbalanced, wrong_child, child_weight + diff}
          end
      end
    end
  end
end
