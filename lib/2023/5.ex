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
      123
  """
  def p2(input) do
    map =
      input
      |> parse()

    map.seeds
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.with_index()
    |> Enum.map(fn {[seed, range], index} ->
      IO.puts("Start index #{index} with seed #{seed} and range #{range}")
      res =
        seed..(seed + range + 1)
        |> Enum.map(fn number ->
          if rem(number, 10000000) == 0 do
            IO.puts("Index: #{index} -- Number #{number} (Start: #{seed}) -- End: #{seed + range})")
          end

          number
          |> p1_next_number(map.seed_to_soil_map)
          |> p1_next_number(map.soil_to_fertilizer_map)
          |> p1_next_number(map.fertilizer_to_water_map)
          |> p1_next_number(map.water_to_light_map)
          |> p1_next_number(map.light_to_temperature_map)
          |> p1_next_number(map.temperature_to_humidity_map)
          |> p1_next_number(map.humidity_to_location_map)
        end)
        |> Enum.min()

      IO.puts("Index #{index} has result #{res}")
      res
    end)
    |> Enum.min()
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
end
