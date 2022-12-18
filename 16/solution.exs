defmodule Day16 do
  defmodule State do
    defstruct [:nodes, :transitions, :total_time, :current, :seen, :elapsed_time, :score]
    def new(nodes, transitions, total_time, start) do
      %State{
        nodes: nodes,
        transitions: transitions,
        total_time: total_time,
        current: start,
        seen: [],
        elapsed_time: 0,
        score: 0
      }
    end

    def is_final(%State{ elapsed_time: x, total_time: x }), do: true
    def is_final(%State{}), do: false

    def successors(%State{ elapsed_time: x, total_time: x }), do: []
    def successors(state) do
      score_per_tick = state.seen
        |> Enum.map(fn node -> state.nodes[node].rate end)
        |> Enum.sum()

      stahp = %State { state |
        elapsed_time: state.total_time,
        score: state.score + (score_per_tick * (state.total_time - state.elapsed_time))
      }

      moar = state.transitions[state.current]
        |> Enum.filter(fn t -> is_valid_transition(state, t) end)
        |> Enum.map(fn { next, distance } ->
          %State { state |
            seen: [next | state.seen],
            current: next,
            elapsed_time: state.elapsed_time + distance,
            score: state.score + (score_per_tick * distance)
          }
        end)
      [stahp | moar]
    end

    defp is_valid_transition(state, { next, distance }) do
      not Enum.member?(state.seen, next)
        and state.elapsed_time + distance <= state.total_time
    end
  end

  def part1(input) do
    nodes = Map.new(Enum.map(input, &parse_line/1))
    transitions = find_transitions(nodes)
    state = State.new(nodes, transitions, 30, "AA")
    find_best_state(state).score
  end
  def part2(input) do
    nodes = Map.new(Enum.map(input, &parse_line/1))
    transitions = find_transitions(nodes)
    partitions = find_partitions(Map.keys(Map.delete(transitions, "AA")))
    combinations = for { dests, _ } <- partitions, do: dests
    solo_scores = find_scores_from_combinations(nodes, transitions, combinations)
    scores = for { my_dests, elephant_dests } <- partitions do
      my_score = solo_scores[my_dests]
      elephant_score = solo_scores[elephant_dests]
      my_score + elephant_score
    end
    Enum.max(scores)
  end

  defp parse_line(line) do
    [
      <<"Valve ", name::binary-size(2), " has flow rate=", rate::binary>>,
      valves
    ] = String.split(line, "; ")
    { name, %{ rate: String.to_integer(rate), valves: parse_valves(valves) } }
  end
  defp parse_valves("tunnel leads to valve " <> valve), do: [valve]
  defp parse_valves("tunnels lead to valves " <> valves), do: String.split(valves, ", ")

  defp find_transitions(nodes) do
    for { src, %{ rate: rate } } <- nodes, src == "AA" or rate > 0, into: %{} do
      paths = find_shortest_paths(src, nodes)
      transitions = for { dest, path } <- paths, dest != src and nodes[dest].rate > 0, into: %{} do
        { dest, length(path) } # -1 because paths include start, +1 for time taken to open valve
      end
      { src, transitions }
    end
  end
  defp find_shortest_paths(start, nodes) do
    frontier = :queue.new()
    paths = %{}
    bfs(nodes, { frontier, paths }, [start])
  end
  defp bfs(nodes, { frontier, paths }) do
    { next, frontier } = :queue.out(frontier)
    case next do
      { :value, current } -> bfs(nodes, { frontier, paths }, current)
      :empty -> paths
    end
  end
  defp bfs(nodes, { frontier, paths }, [current|_] = path) do
    if Map.has_key?(paths, current) do
      bfs(nodes, { frontier, paths })
    else
      frontier = for next <- nodes[current].valves, reduce: frontier do
        f -> :queue.in([next | path], f)
      end
      paths = Map.put(paths, current, path)
      bfs(nodes, { frontier, paths })
    end
  end

  defp find_best_state(state) do
    find_final_states(state)
      |> Enum.max_by(fn state -> state.score end)
  end
  defp find_final_states(state) do
    if State.is_final(state) do
      [state]
    else
      Enum.flat_map(State.successors(state), &find_final_states/1)
    end
  end

  defp find_scores_from_combinations(nodes, transitions, combinations) do
    Enum.reduce(combinations, %{}, fn dests, scores ->
      if Map.has_key?(scores, dests) do
        scores
      else
        filtered = filter_transitions(transitions, dests)
        state = find_best_state(State.new(nodes, filtered, 26, "AA"))
        for combos <- find_redundant_combinations(dests, state.seen), into: scores do
          { combos, state.score }
        end
      end
    end)
  end

  defp find_redundant_combinations(dests, seen) do
    seen = MapSet.new(seen)
    redundants = MapSet.difference(MapSet.new(dests), seen)
    for extras <- find_combinations(Enum.to_list(redundants)) do
      all_to_include = MapSet.union(seen, MapSet.new(extras))
      Enum.filter(dests, fn dest -> MapSet.member?(all_to_include, dest) end)
    end
  end

  defp filter_transitions(transitions, valid_dests) do
    dests = MapSet.new(valid_dests)
    for { src, transitions } <- transitions, src == "AA" or MapSet.member?(dests, src), into: %{} do
      filtered = for { dest, score } <- transitions, MapSet.member?(dests, dest), into: %{}, do: { dest, score }
      { src, filtered }
    end
  end

  defp find_combinations([]), do: [[]]
  defp find_combinations([x|xs]) do
    rest = find_combinations(xs)
    Enum.map(rest, fn cs -> [x | cs] end) ++ rest
  end
  defp find_partitions([]), do: [{[], []}]
  defp find_partitions([x|xs]) do
    rest = find_partitions(xs)
    in_first = Enum.map(rest, fn {p1, p2} -> {[x|p1], p2} end)
    in_second = Enum.map(rest, fn {p1, p2} -> {p1, [x|p2]} end)
    in_first ++ in_second
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day16.part1(input))
IO.puts(Day16.part2(input))
