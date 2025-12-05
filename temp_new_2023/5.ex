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
    {seeds, maps} = parse(input)
    
    seeds
    |> Enum.map(fn seed -> apply_maps(seed, maps) end)
    |> Enum.min()
  end

  @doc """
      iex> p2(example_string())
      46

      iex> p2(input_string())
      20283860
  """
  def p2(input) do
    {seeds, maps} = parse(input)
    
    seed_ranges = seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, len] -> {start, start + len - 1} end)
    
    maps
    |> Enum.reduce(seed_ranges, fn map, ranges ->
      ranges |> Enum.flat_map(fn range -> apply_map_to_range(range, map) end)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  defp parse(input) do
    [seeds_line | map_sections] = String.split(input, "\n\n", trim: true)
    
    seeds = seeds_line
    |> String.replace("seeds: ", "")
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    
    maps = Enum.map(map_sections, &parse_map/1)
    
    {seeds, maps}
  end

  defp parse_map(section) do
    [_header | lines] = String.split(section, "\n", trim: true)
    
    lines
    |> Enum.map(fn line ->
      [dest, src, len] = line |> String.split() |> Enum.map(&String.to_integer/1)
      {src, src + len - 1, dest - src}
    end)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp apply_maps(value, maps) do
    Enum.reduce(maps, value, fn map, val ->
      case Enum.find(map, fn {src_start, src_end, _offset} -> val >= src_start and val <= src_end end) do
        nil -> val
        {_, _, offset} -> val + offset
      end
    end)
  end

  defp apply_map_to_range({range_start, range_end}, map_rules) do
    apply_map_to_range_helper({range_start, range_end}, map_rules, [])
  end

  defp apply_map_to_range_helper({range_start, range_end}, [], acc) do
    [{range_start, range_end} | acc]
  end

  defp apply_map_to_range_helper({range_start, range_end}, [{src_start, src_end, offset} | rest], acc) do
    cond do
      # Range entirely before this mapping
      range_end < src_start ->
        [{range_start, range_end} | acc]
      
      # Range entirely after this mapping
      range_start > src_end ->
        apply_map_to_range_helper({range_start, range_end}, rest, acc)
      
      # Range overlaps with mapping
      true ->
        # Part before mapping (unmapped)
        acc = if range_start < src_start do
          [{range_start, src_start - 1} | acc]
        else
          acc
        end
        
        # Overlapping part (mapped)
        overlap_start = max(range_start, src_start)
        overlap_end = min(range_end, src_end)
        acc = [{overlap_start + offset, overlap_end + offset} | acc]
        
        # Part after mapping
        if range_end > src_end do
          apply_map_to_range_helper({src_end + 1, range_end}, rest, acc)
        else
          acc
        end
    end
  end
end
