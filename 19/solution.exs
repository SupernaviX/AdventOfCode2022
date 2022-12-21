defmodule Day19 do
  defmodule Blueprints do
    alias Day19.Blueprints
    @regex ~r/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./
    defstruct [:id, :costs]
    def parse(line) do
      [id, ore, clay, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian] = Regex.run(@regex, line, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      %Blueprints{
        id: id,
        costs: %{
          :ore => %{ :ore => ore },
          :clay => %{ :ore => clay },
          :obsidian => %{
            :ore => obsidian_ore,
            :clay => obsidian_clay
          },
          :geode => %{
            :ore => geode_ore,
            :obsidian => geode_obsidian
          }
        }
      }
    end

    def cost(blueprints, bot), do: blueprints.costs[bot]
  end

  defmodule Resources do
    def all(), do: [:ore, :clay, :obsidian, :geode]
  end

  defmodule Simulation do
    defstruct [
      :blueprints,
      :minutes_left,
      choices: [],
      bots: %{ :ore => 1, :clay => 0, :obsidian => 0, :geode => 0 },
      resources: %{ :ore => 0, :clay => 0, :obsidian => 0, :geode => 0 }
    ]
    def max_geodes(blueprints, minutes_left) do
      sim = %Simulation{ blueprints: blueprints, minutes_left: minutes_left }
      maximize_geodes(sim, { 0, [] })
    end
    defp maximize_geodes(%Simulation{ minutes_left: 0 } = sim, _) do
      { sim.resources[:geode], sim.choices }
    end
    defp maximize_geodes(sim, max_so_far) do
      for option <- next_options(sim), reduce: max_so_far do max_so_far ->
        if vague_maximum_heuristic(option) > elem(max_so_far, 0) do
          max(max_so_far, maximize_geodes(option, max_so_far))
        else
          max_so_far
        end
      end
    end

    defp vague_maximum_heuristic(sim) do
      # if we build a geode bot every remaining minute, how well could we do
      for i <- 0..sim.minutes_left, reduce: sim.resources[:geode] do sum ->
        sum + sim.bots[:geode] + i
      end
    end

    defp next_options(sim) do
      opts = Resources.all()
        |> Enum.map(fn bot -> { bot, try_build(sim, bot) } end)
        |> Enum.filter(fn { _, res } -> not is_nil(res) end)
        |> Map.new()
      # If we have an obsidian bot, we've made enough ore bots already.
      # If we have a geode bot, we've made enough clay bots as well.
      options = cond do
        sim.bots[:geode] > 0 -> Map.values(Map.delete(Map.delete(opts, :ore), :clay))
        sim.bots[:obsidian] > 0 -> Map.values(Map.delete(opts, :ore))
        true -> Map.values(opts)
      end
      if options == [], do: [just_wait(sim)], else: options
    end

    defp try_build(sim, bot) do
      cost = Blueprints.cost(sim.blueprints, bot)
      wait_time = time_to_next(sim, bot)
      cond do
        wait_time >= sim.minutes_left -> nil
        not useful_to_build(sim, bot) -> nil
        true ->
          new_minutes_left = sim.minutes_left - wait_time
          new_bots = add_maps(sim.bots, %{ bot => 1 })
          new_resources = sim.resources
            |> add_maps(mult_map(sim.bots, wait_time))
            |> sub_maps(cost)
          %Simulation{ sim |
            minutes_left: new_minutes_left,
            bots: new_bots,
            resources: new_resources,
            choices: [{ new_minutes_left, bot } | sim.choices]
          }
      end
    end
    defp just_wait(sim) do
      %Simulation{ sim |
        minutes_left: 0,
        resources: add_maps(sim.resources, mult_map(sim.bots, sim.minutes_left))
      }
    end

    defp time_to_next(sim, bot) do
      cost = Blueprints.cost(sim.blueprints, bot)
      Enum.max(for { res, need } <- cost do
        have = sim.resources[res]
        growth_rate = sim.bots[res]
        if growth_rate == 0 do
          :infinity
        else
          minutes_gathering = max(0, trunc(Float.ceil((need - have) / growth_rate)))
          1 + minutes_gathering
        end
      end)
    end

    defp useful_to_build(_, :geode), do: true
    defp useful_to_build(sim, resource) do
      # no point in building something if we produce as much of it in one turn as we can use
      max_useful = Enum.max(for bot <- Resources.all() do
        costs = Blueprints.cost(sim.blueprints, bot)
        Map.get(costs, resource, 0)
      end)
      sim.bots[resource] < max_useful
    end

    defp add_maps(map1, map2), do: Map.merge(map1, map2, fn _, val1, val2 -> val1 + val2 end)
    defp sub_maps(map1, map2), do: Map.merge(map1, map2, fn _, val1, val2 -> val1 - val2 end)
    defp mult_map(map, amount) do
      Map.new(for { key, value } <- map, do: { key, value * amount })
    end
  end

  def part1(input) do
    for blueprint <- Enum.map(input, &Blueprints.parse/1), reduce: 0 do
      sum ->
        { max, _choices } = Simulation.max_geodes(blueprint, 24)
        #IO.inspect({ blueprint.id, max, Enum.reverse(choices) })
        sum + (blueprint.id * max)
    end
  end
  def part2(input) do
    blueprints = Enum.map(input, &Blueprints.parse/1)
    for blueprint <- Enum.take(blueprints, 3), reduce: 1 do
      product ->
        { max, _choices } = Simulation.max_geodes(blueprint, 32)
        #IO.inspect({ blueprint.id, max, Enum.reverse(choices) })
        product * max
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day19.part1(input))
IO.puts(Day19.part2(input))
