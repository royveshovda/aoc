# Source: https://github.com/flwyd/adventofcode/blob/main/2022/day19/day19.exs
import AOC

aoc 2022, 19 do

  defmodule State do
    @moduledoc false
    defstruct robots: %{ore: 1, clay: 0, obsidian: 0, geode: 0},
              resources: %{ore: 0, clay: 0, obsidian: 0, geode: 0}

    def score(state), do: state.resources.geode

    def build(state, type, cost) do
      struct!(state,
        robots: Map.update!(state.robots, type, &(&1 + 1)),
        resources: Map.merge(state.resources, cost, fn _k, v1, v2 -> v1 - v2 end)
      )
    end

    def can_build?(state, cost), do: Enum.all?(cost, fn {k, v} -> v <= state.resources[k] end)

    def add_resources(state, res) do
      struct!(state,
        resources: Map.merge(state.resources, res, fn _k, v1, v2 -> v1 + v2 end)
      )
    end

    def all_possible(state, blueprint, time) do
      [
        state
        | [:geode, :obsidian, :ore, :clay]
          |> Enum.filter(&can_build?(state, blueprint[&1]))
          |> Enum.filter(&worthwhile(state, blueprint, time, &1))
          |> Enum.take(2)
          |> Enum.map(&build(state, &1, blueprint[&1]))
      ]
    end

    def worthwhile(_, _, time, :geode), do: time > 1

    def worthwhile(_, _, time, :obsidian) when time <= 2, do: false

    def worthwhile(state, blueprint, time, :obsidian) do
      expensive = blueprint.geode.obsidian
      state.resources.obsidian + state.robots.obsidian * (time - 2) < (time - 1) * expensive
    end

    def worthwhile(_, _, time, :ore) when time <= 2, do: false

    def worthwhile(state, blueprint, time, :ore) do
      expensive = Enum.max([blueprint.geode.ore, blueprint.obsidian.ore, blueprint.clay.ore])
      state.resources.ore + state.robots.ore * (time - 2) < (time - 1) * expensive
    end

    def worthwhile(_, _, time, :clay) when time <= 3, do: false

    def worthwhile(state, blueprint, time, :clay) do
      expensive = blueprint.obsidian.clay
      state.resources.clay + state.robots.clay * (time - 3) < (time - 2) * expensive
    end

    def discard_unnecessary(state, bp, time) do
      struct!(state,
        resources: %{
          ore:
            min(
              state.resources.ore,
              Enum.max([bp.geode.ore, bp.obsidian.ore, bp.clay.ore, bp.ore.ore]) * (time - 1)
            ),
          clay: min(state.resources.clay, bp.obsidian.clay * (time - 1)),
          obsidian: min(state.resources.obsidian, bp.geode.obsidian * (time - 1)),
          geode: state.resources.geode
        }
      )
    end

    def sorter(a, b) do
      [al, bl] =
        Enum.map([a, b], fn x ->
          [x.robots.geode, x.robots.obsidian, x.robots.clay, x.robots.ore]
        end)

      al >= bl
    end
  end

  def p1(input) do
    # blueprints =
    #   input
    #   |> String.split("\n")
    #   |> Enum.map(&parse_blueprint/1)

    # start = %{
    #   ore: 0,
    #   clay: 0,
    #   obsidian: 0,
    #   geode: 0,
    #   nothing: 0,
    #   robots: %{
    #     ore: 1,
    #     clay: 0,
    #     obsidian: 0,
    #     geode: 0,
    #     nothing: 0
    #   }
    # }

    # #options_to_build(start, hd(blueprints))

    # blueprints
    # |> Enum.map(fn blueprint ->
    #   Task.async(fn ->
    #     IO.puts(:stderr, "#{inspect(self())} checking blueprint #{inspect(blueprint)}")
    #     {blueprint.id, score(start, blueprint, 24)}
    #   end)
    # end)
    # |> Task.await_many(:infinity)
    # |> Enum.map(fn {id, score} -> id * score end)
    # |> Enum.sum()

    blueprints =
      input
      |> String.split("\n")
      |> Enum.map(&parse_line/1)

    Enum.map(blueprints, fn bp ->
      Task.async(fn ->
        IO.puts(:stderr, "#{inspect(self())} checking blueprint #{inspect(bp)}")
        {bp.id, best_score(%State{}, bp, 24)}
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.map(fn {id, score} -> id * score end)
    |> Enum.sum()
  end

  def collect(state) do
    state
    |> Map.put(:ore, state.ore + state.robots.ore)
    |> Map.put(:clay, state.clay + state.robots.clay)
    |> Map.put(:obsidian, state.obsidian + state.robots.obsidian)
    |> Map.put(:geode, state.geode + state.robots.geode)
  end

  def options_to_build(state, blueprint) do
    ore = blueprint.ore |> Enum.all?(fn {resource, count} -> state[resource] >= count end)
    clay = blueprint.clay |> Enum.all?(fn {resource, count} -> state[resource] >= count end)
    obsidian = blueprint.obsidian |> Enum.all?(fn {resource, count} -> state[resource] >= count end)
    geode = blueprint.geode |> Enum.all?(fn {resource, count} -> state[resource] >= count end)

    %{
      ore: ore,
      clay: clay,
      obsidian: obsidian,
      geode: geode
    }
    |> Map.to_list
    |> Enum.filter(fn {_, found} -> found end)
    |> Enum.map(fn {type, _} -> type end)
    |> List.insert_at(0, :nothing)
  end

  def score(state, _, 0) do
    state.geode
  end

  def score(state, blueprint, remaining_time) do
    options = options_to_build(state, blueprint)

    options
    |> Enum.map(fn option ->
      state
      |> build(blueprint, option)
      |> collect()
      |> score(blueprint, remaining_time - 1)
    end)
    |> Enum.max()
  end

  def build(state, blueprint, option) do
    Enum.reduce(blueprint[option], state, fn {resource, count}, state ->
      Map.put(state, resource, state[resource] - count)
    end)
  end

  def p2(input) do
    blueprints =
      input
      |> String.split("\n")
      |> Enum.take(3)
      |> Enum.map(&parse_line/1)

    Enum.map(blueprints, fn bp ->
      Task.async(fn ->
        IO.puts(:stderr, "#{inspect(self())} checking blueprint #{inspect(bp)}")
        best_score(%State{}, bp, 32)
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.product()
  end


  def parse_blueprint(blueprint) do
    [id, rest] = String.split(blueprint, ":")
    id = id |> String.trim_leading("Blueprint ") |> String.to_integer()

    [ore, clay, obsidian, geode] = String.split(rest, ".", trim: true)
    ore = ore |> String.trim_leading(" Each ore robot costs ") |> parse_cost() |> Map.new()
    clay = clay |> String.trim_leading(" Each clay robot costs ") |> parse_cost()
    obsidian = obsidian |> String.trim_leading(" Each obsidian robot costs ") |> parse_cost()
    geode = geode |> String.trim_leading(" Each geode robot costs ") |> parse_cost()

    %{
      id: id,
      ore: ore,
      clay: clay,
      obsidian: obsidian,
      geode: geode,
      nothing: []
    }
  end

  def parse_cost(cost) do
    cost
    |> String.split(" and ")
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [count, resource] ->
      {String.to_atom(resource), String.to_integer(count)}
    end)
  end



  defp best_score(state, bp, time) do
    cache = :ets.new(String.to_atom("cache_#{bp.id}"), [:set])
    stats = :ets.new(String.to_atom("stats_#{bp.id}"), [:set])
    :ets.update_counter(stats, :hits, 0, {:hits, 0})
    :ets.update_counter(stats, :misses, 0, {:misses, 0})
    {best, path} = best_score(state, bp, time, cache, stats)
    IO.puts(:stderr, "Blueprint #{bp.id} got #{best} #{inspect(self())}")

    [hits, misses] =
      Enum.map([:hits, :misses], fn key -> Keyword.fetch!(:ets.lookup(stats, key), key) end)

    IO.puts(:stderr, "Cache hits: #{hits} misses: #{misses} #{inspect(self())}")
    :ets.delete(cache)
    :ets.delete(stats)
    for {state, i} <- Enum.with_index(path, 1), do: IO.puts(:stderr, "Step #{i}: #{inspect(state)}")
    best
  end

  defp best_score(state, _bp, 0, _cache, _stats), do: {State.score(state), []}

  defp best_score(state, bp, time, cache, stats) do
    cache_key = {State.discard_unnecessary(state, bp, time), time}

    case :ets.lookup(cache, cache_key) do
      [{_, cached}] ->
        hits = :ets.update_counter(stats, :hits, 1, {:hits, 0})

        if rem(hits, 10_000_000) == 0,
          do: IO.puts(:stderr, "#{hits} cache hits time #{time} #{inspect(self())}")

        cached

      [] ->
        to_add = state.robots
        misses = :ets.update_counter(stats, :misses, 1, {:misses, 0})

        if rem(misses, 10_000_000) == 0,
          do: IO.puts(:stderr, "#{misses} cache misses time #{time} #{inspect(self())}")

        State.all_possible(state, bp, time)
        |> Enum.map(&State.add_resources(&1, to_add))
        |> Enum.map(fn x ->
          {best, path} = best_score(x, bp, time - 1, cache, stats)
          {best, [x | path]}
        end)
        |> Enum.max_by(fn {score, _} -> score end)
        |> tap(fn best -> :ets.insert(cache, {cache_key, best}) end)
    end
  end

  @pattern ~r/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./
  defp parse_line(line) do
    [id, ore_cost, clay_cost, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian] =
      Regex.run(@pattern, line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)

    %{
      id: id,
      ore: %{ore: ore_cost},
      clay: %{ore: clay_cost},
      obsidian: %{ore: obsidian_ore, clay: obsidian_clay},
      geode: %{ore: geode_ore, obsidian: geode_obsidian}
    }
  end
end
