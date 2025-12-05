import AOC

aoc 2020, 4 do
  @moduledoc """
  https://adventofcode.com/2020/day/4

  Passport Processing - Validate passport data fields.
  """

  @required_fields ~w(byr iyr eyr hgt hcl ecl pid)

  @doc """
  Count passports with all required fields present.

  ## Examples

      iex> input = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\\nbyr:1937 iyr:2017 cid:147 hgt:183cm\\n\\niyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\\nhcl:#cfa07d byr:1929\\n\\nhcl:#ae17e1 iyr:2013\\neyr:2024\\necl:brn pid:760753108 byr:1931\\nhgt:179cm\\n\\nhcl:#cfa07d eyr:2025 pid:166559648\\niyr:2011 ecl:brn hgt:59in"
      iex> p1(input)
      2
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.count(&has_required_fields?/1)
  end

  @doc """
  Count passports with valid field values.
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.count(&valid_passport?/1)
  end

  defp parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_passport/1)
  end

  defp parse_passport(passport) do
    passport
    |> String.split(~r/[\s\n]+/, trim: true)
    |> Enum.map(fn pair ->
      [key, value] = String.split(pair, ":")
      {key, value}
    end)
    |> Map.new()
  end

  defp has_required_fields?(passport) do
    Enum.all?(@required_fields, &Map.has_key?(passport, &1))
  end

  defp valid_passport?(passport) do
    has_required_fields?(passport) and
      valid_byr?(passport["byr"]) and
      valid_iyr?(passport["iyr"]) and
      valid_eyr?(passport["eyr"]) and
      valid_hgt?(passport["hgt"]) and
      valid_hcl?(passport["hcl"]) and
      valid_ecl?(passport["ecl"]) and
      valid_pid?(passport["pid"])
  end

  defp valid_byr?(val), do: valid_year?(val, 1920, 2002)
  defp valid_iyr?(val), do: valid_year?(val, 2010, 2020)
  defp valid_eyr?(val), do: valid_year?(val, 2020, 2030)

  defp valid_year?(val, min, max) do
    case Integer.parse(val) do
      {year, ""} -> year >= min and year <= max
      _ -> false
    end
  end

  defp valid_hgt?(val) do
    case Regex.run(~r/^(\d+)(cm|in)$/, val) do
      [_, num, "cm"] ->
        {h, ""} = Integer.parse(num)
        h >= 150 and h <= 193
      [_, num, "in"] ->
        {h, ""} = Integer.parse(num)
        h >= 59 and h <= 76
      _ -> false
    end
  end

  defp valid_hcl?(val), do: Regex.match?(~r/^#[0-9a-f]{6}$/, val)

  defp valid_ecl?(val), do: val in ~w(amb blu brn gry grn hzl oth)

  defp valid_pid?(val), do: Regex.match?(~r/^\d{9}$/, val)
end
