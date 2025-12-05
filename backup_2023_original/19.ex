import AOC

aoc 2023, 19 do
  @moduledoc """
  https://adventofcode.com/2023/day/19
  """

  @doc """
      iex> p1(example_string())
      19114

      iex> p1(input_string())
      434147
  """
  def p1(input) do
    {rules, xmas} =
      input
      |> parse_input()

    xmas
    |> Enum.map(fn x -> execute_p1(rules, x, rules["in"]) end)
    |> Enum.filter(fn
      {:accepted, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {:accepted, %{"x" => x, "m" => m, "a" => a, "s" => s}} -> x + m + a + s end)
    |> Enum.sum()

  end

  def execute_p1(rules, xmas, [current_rule | rest]) do
    case current_rule do
      {:accept} -> {:accepted, xmas}
      {:reject} -> :rejected
      {:go_to, label} -> execute_p1(rules, xmas, rules[label])
      {:condition, v, ltgt, value, op} ->
        case ltgt do
          "<" ->
            if xmas[v] < value do
              execute_p1(rules, xmas, [op])
            else
              execute_p1(rules, xmas, rest)
            end
          ">" ->
            if xmas[v] > value do
              execute_p1(rules, xmas, [op])
            else
              execute_p1(rules, xmas, rest)
            end
        end
    end
  end

  @doc """
      iex> p2(example_string())
      167409079868000

      iex> p2(input_string())
      136146366355609
  """
  def p2(input) do
    {rules, _xmas} =
      input
      |> parse_input()

    search(rules, rules["in"], %{"x" => %{min: 1, max: 4000}, "m" => %{min: 1, max: 4000}, "a" => %{min: 1, max: 4000}, "s" => %{min: 1, max: 4000}})
  end

  def search(_rules, [{:accept} | _], %{"x" => %{min: x_min, max: x_max}, "m" => %{min: m_min, max: m_max}, "a" => %{min: a_min, max: a_max}, "s" => %{min: s_min, max: s_max}}) do
    (x_max - x_min + 1) * (m_max - m_min + 1) * (a_max - a_min + 1) * (s_max - s_min + 1)
  end

  def search(_rules, [{:reject} | _], _) do
    0
  end

  def search(rules, [current_rule | rest], ranges) do
    case current_rule do
      {:go_to, label} -> search(rules, rules[label], ranges)
      {:condition, v, ltgt, value, op} ->
        min = ranges[v][:min]
        max = ranges[v][:max]
        case ltgt do
          "<" ->
            left = search(rules, [op], %{ranges | v => %{min: min, max: value - 1}})
            right = search(rules, rest, %{ranges | v => %{min: value, max: max}})
            left + right
          ">" ->
            left = search(rules, [op], %{ranges | v => %{min: value + 1, max: max}})
            right = search(rules, rest, %{ranges | v => %{min: min, max: value}})
            left + right
        end
    end
  end

  def parse_input(input) do
    [rules, xmas] = String.split(input, "\n\n")
    rules =
      rules
      |> String.split("\n")
      |> Enum.map(fn l ->
          [label, conditions] = String.split(l, "{")
          condition =
            String.trim(conditions, "}")
            |> parse_rules()
          {label, condition}
        end)
      |> Enum.into(%{})

    xmas =
      xmas
      |> String.split("\n")
      |> Enum.map(fn l -> l |> String.trim("{") |> String.trim("}") |> String.split(",") end)
      |> Enum.map(fn [x, m, a, s] ->
        x = String.slice(x, 2..-1//-1) |> String.to_integer()
        m = String.slice(m, 2..-1//-1) |> String.to_integer()
        a = String.slice(a, 2..-1//-1) |> String.to_integer()
        s = String.slice(s, 2..-1//-1) |> String.to_integer()
        %{"x" => x, "m" => m, "a" => a, "s" => s}
      end)
    {rules, xmas}
  end

  def parse_rules(input) do
    input
    |> String.split(",")
    |> Enum.map(fn l ->
      ops = String.split(l, ":")
      parse_rule(ops)
    end)
  end

  def parse_rule(["A"]), do: {:accept}
  def parse_rule(["R"]), do: {:reject}
  def parse_rule([label]), do: {:go_to, label}

  def parse_rule([condition, operation]) do
    v = String.at(condition, 0)
    ltgt = String.at(condition, 1)
    value = String.slice(condition, 2..-1//-1) |> String.to_integer()

    op = parse_rule([operation])
    {:condition, v, ltgt, value, op}
  end
end
