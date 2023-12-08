import AOC

aoc 2023, 5 do
  @moduledoc """
  https://adventofcode.com/2023/day/5
  """

  @doc """
      iex> p1(example_string())
      35

      iex> p1(input_string())
      313045984
  """
  def p1(input) do
    map =
      input
      |> parse()


      map.seeds
      |> Enum.map(fn seed ->
        seed
        |> p1_next_number(map.seed_to_soil_map)
        |> p1_next_number(map.soil_to_fertilizer_map)
        |> p1_next_number(map.fertilizer_to_water_map)
        |> p1_next_number(map.water_to_light_map)
        |> p1_next_number(map.light_to_temperature_map)
        |> p1_next_number(map.temperature_to_humidity_map)
        |> p1_next_number(map.humidity_to_location_map)
      end)
      |> Enum.min()
  end

  @doc """
      iex> p2(example_string())
      46

      iex> p2(input_string())
      20283860
  """
  def p2(input) do
    data =
      input
      |> String.split("\n")
      |> Enum.reverse
      |> tl
      |> Enum.reverse

    {:ok, seeds, _, _, _, _} =
      data
      |> hd
      |> Aoc23.Day05Parser.parseSeeds

    data = tl(tl(data))

    stages = generate_stages(data, [])

    pairs = gen_pairs(seeds)

    pairs
    |> Enum.flat_map(fn pair -> progress_seed(pair, stages) end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.min
  end

  def p1_next_number(number, map) do
    case part_of_map?(number, map) do
      false -> number
      true -> p1_next_number_with_map(number, map)
    end
  end

  def part_of_map?(number, map) do
    map
    |> Enum.any?(fn %{source: source, target: _target, length: length} -> number >= source and number <= source + length end)
  end

  def p1_next_number_with_map(number, map) do
    correct_map = Enum.find(map, fn %{source: source, target: _target, length: length} -> number >= source and number <= source + length end)
    distance = number - correct_map.source
    correct_map.target + distance
  end

  def parse(input) do
    [seeds_r, seed_to_soil_r, soil_to_fert_r, fert_to_water_r, water_to_light_r, light_to_temp_r, temp_to_humid_r, humid_to_location_r] = String.split(input, "\n\n", trim: true)
    seeds = parse_seeds(seeds_r)
    seed_to_soil_map = parse_map(seed_to_soil_r)
    soil_to_fertilizer_map = parse_map(soil_to_fert_r)
    fertilizer_to_water_map = parse_map(fert_to_water_r)
    water_to_light_map = parse_map(water_to_light_r)
    light_to_temperature_map = parse_map(light_to_temp_r)
    temperature_to_humidity_map = parse_map(temp_to_humid_r)
    humidity_to_location_map = parse_map(humid_to_location_r)
    %{
      seeds: seeds,
      seed_to_soil_map: seed_to_soil_map,
      soil_to_fertilizer_map: soil_to_fertilizer_map,
      fertilizer_to_water_map: fertilizer_to_water_map,
      water_to_light_map: water_to_light_map,
      light_to_temperature_map: light_to_temperature_map,
      temperature_to_humidity_map: temperature_to_humidity_map,
      humidity_to_location_map: humidity_to_location_map
    }
  end

  def parse_map(map) do
    [_first_line_is_heading_and_dropped | lines] = String.split(map, "\n", trim: true)
    lines
    |> Enum.map(fn line ->
      [target, source, length] = String.split(line, " ", trim: true)
      %{source: String.to_integer(source), target: String.to_integer(target), length: String.to_integer(length)}
    end)
  end

  def parse_seeds(seeds_r) do
    ["seeds", seed_list] = String.split(seeds_r, ":", trim: true)
    seed_list
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  # Part 2
  def progress_seed(seed, stages) do
      for stage <- stages, reduce: [seed] do
        acc -> Enum.flat_map(acc, fn item -> progress_stage(item, stage,[]) end)
      end
    end

    def progress_stage({key, len}, stage, result) do
      {src, dest, stage_len} = lookup(stage, {key, len})
      if (src + stage_len) >= (key + len) do
        [{dest + (key - src), len} | result]
      else
        consumed_len = (src + stage_len) - key
        progress_stage({key + consumed_len, len - consumed_len}, stage, [{dest + (key - src), consumed_len} | result])
      end
    end

    # Binary search to find the correct transform for a key in a stage
    def lookup(stage, seed), do: lookup(stage, seed, 0, Arrays.size(stage) - 1)
    def lookup(stage, {seed_low, seed_len}, l, r) do
      if l > r do
        {seed_low, seed_low, seed_len}
      else
        m = div(l + r, 2)
        {src, _, stage_len} = stage[m]
        cond do
          src + stage_len <= seed_low -> lookup(stage, {seed_low, seed_len}, m + 1, r)
          src > seed_low -> lookup(stage, {seed_low, seed_len}, l, m - 1)
          true -> stage[m]
        end
      end
    end

  def generate_stages(nil, result), do: Enum.reverse(result)
    def generate_stages(data, result) do
      {stage, remaining} = process_stage(data)
      generate_stages(remaining, [stage | result])
    end

    def gen_pairs(seeds), do: gen_pairs(seeds, [])
    def gen_pairs([], result), do: result
    def gen_pairs([l | [len | rest]], result), do: gen_pairs(rest, [{l, len} | result])

    def fill_stage(stage), do: fill_stage(stage, 0, [])
    def fill_stage([], _, result), do: result
    def fill_stage([{s, d, l} | rest], current, result) do
      if (current < s) do
        fill_stage(rest, s + l, [{s,d,l} | [{current, current, s - current} | result]])
      else
        fill_stage(rest, s + l, [{s,d,l} | result])
      end
    end

    def finalize_stage(stage, data) do
      stage
      |> Enum.sort(fn {s1, _, _}, {s2, _, _} -> s1 <= s2 end)
      |> fill_stage
      |> Enum.reverse
      |> Enum.into(Arrays.new())
      |> then(fn arr -> {arr, data} end)
    end

    def process_stage(data), do: process_stage(tl(data), [])
    def process_stage([], result), do: finalize_stage(result, nil)
    def process_stage([line | rest], result) do
      case line do
        "" ->
          finalize_stage(result, rest)
        _ ->
          {:ok, parsed_line, _, _, _, _} = Aoc23.Day05Parser.parseMap line
          process_stage(rest, [transform_line(parsed_line) | result])
      end
    end

    def transform_line([dest, source, len]), do: {source, dest, len}
end

defmodule Aoc23.Day05Parser do
  import NimbleParsec

  whitespace =
    repeat(ignore(string(" ")))

  number =
  whitespace
  |> concat(integer(min: 1))
  |> concat(whitespace)

  seeds =
  ignore(string("seeds:"))
  |> concat(repeat(number))

  map =
    number
    |> concat(number)
    |> concat(number)

  defparsec(:parseSeeds, seeds)
  defparsec(:parseMap, map)
end
