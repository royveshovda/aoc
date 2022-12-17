# Heavilly borrowed from https://github.com/rewritten/aoc.ex/blob/main/2022/Day%2016:%20Proboscidea%20Volcanium.livemd

import AOC
import NimbleParsec

aoc 2022, 16 do
  def p1(input) do
    build_paths(input, 30)
    |> Enum.max_by(& &1.total)
  end

  def build_paths(input, max_time) do
    data =
      for line <- String.split(input, "\n", trim: true),
          {:ok, parsed, _, _, _, _} = Parser.line(line),
          do: Map.new(parsed)

    nodes = for d <- data, d.flow > 0 or length(d.destinations) != 2, do: d.source

    data_by_source = Map.new(data, &{&1.source, &1})

    flows = for d <- data, into: %{}, do: {d.source, d.flow}

    follow = fn node, next ->
      [next, node]
      |> Stream.iterate(fn [h | t] ->
        if h not in nodes, do: [hd(data_by_source[h].destinations -- t), h | t]
      end)
      |> Enum.take_while(& &1)
      |> List.last()
    end

    lengths =
      for node <- nodes, dest <- data_by_source[node].destinations, into: %{} do
        path = follow.(node, dest)
        {[node, hd(path)], length(path) - 1}
      end

    fill_in_distances = fn known_distances ->
      new_pairs =
        for {p, dp} <- known_distances,
            {q, dq} <- known_distances,
            p != q,
            MapSet.intersection(p, q) |> MapSet.size() == 1,
            pq = MapSet.difference(MapSet.union(p, q), MapSet.intersection(p, q)),
            not is_map_key(known_distances, pq),
            do: {pq, dp + dq}

      best_computed_distances =
        new_pairs
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Map.new(fn {p, ds} -> {p, Enum.min(ds)} end)

      Map.merge(known_distances, best_computed_distances)
    end

    initial = for {p, d} <- lengths, into: %{}, do: {MapSet.new(p), d}

    all_distances =
      initial
      |> then(fill_in_distances)
      |> then(fill_in_distances)
      |> then(fill_in_distances)

    all_distances_from =
      all_distances
      |> Enum.flat_map(fn {pair, d} ->
        [p, q] = Enum.to_list(pair)
        [{p, q, d}, {q, p, d}]
      end)
      |> Enum.reduce(%{}, fn {p, q, d}, acc ->
        Map.update(acc, p, %{q => d}, &Map.put(&1, q, d))
      end)


    initial = %{p: ["AA"], t: max_time, flow: 0, total: 0}
    queue = :queue.new()
    queue = :queue.in(initial, queue)

    Stream.resource(
      fn -> queue end,
      fn queue ->
        case :queue.out(queue) do
          {:empty, _} ->
            {:halt, nil}

          {{:value, current}, next} ->
            %{p: [h | t], t: time} = current

            opened = %{
              current
              | t: time - 1,
                flow: current.flow + flows[h],
                total: current.total + current.flow
            }

            next_paths =
              for {q, d} <- all_distances_from[h], d < time, q not in t do
                new_p = [q, h | t]
                new_t = opened.t - d
                %{opened | p: new_p, t: new_t, total: opened.total + d * opened.flow}
              end

            new_flow = opened.flow + flows[hd(opened.p)]
            new_total = opened.total + (opened.t + 1) * opened.flow
            finished = %{opened | flow: new_flow, total: new_total}

            {[finished], Enum.reduce(next_paths, next, &:queue.in/2)}
        end
      end,
      & &1
    )
  end

  def p2(input) do
    p26 =
      build_paths(input, 26)
      |> Enum.reduce(%{}, fn x, acc ->
        Map.update(acc, MapSet.new(x.p -- ["AA"]), x.total, &max(&1, x.total))
      end)

    Enum.max(
      for {p, c} <- p26,
          {ep, ec} <- p26,
          MapSet.disjoint?(p, ep),
          do: c + ec
    )
  end
end

defmodule Parser do
  import NimbleParsec

  valve = ignore(string(" ")) |> ascii_string([?A..?Z], min: 2)

  line =
    ignore(string("Valve"))
    |> unwrap_and_tag(valve, :source)
    |> ignore(string(" has flow rate="))
    |> unwrap_and_tag(integer(min: 1), :flow)
    |> ignore(choice([string("; tunnels lead to valves"), string("; tunnel leads to valve")]))
    |> tag(valve |> repeat(ignore(string(",")) |> concat(valve)), :destinations)

  defparsec(:line, line)
end
