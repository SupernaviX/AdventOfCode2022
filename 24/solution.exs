defmodule Day24 do
  defmodule Valley do
    defstruct [:size, :blizzards, :positions]
    def new(map) do
      { x_max, y_max } = Enum.max(Map.keys(map))
      blizzards = for { pos, { :blizzard, dir } } <- map, do: { pos, dir }
      positions = MapSet.new(blizzards, &elem(&1, 0))
      %Valley{
        size: { x_max, y_max },
        blizzards: blizzards,
        positions: positions
      }
    end

    def next(valley) do
      blizzards = move_blizzards(valley)
      positions = MapSet.new(blizzards, &elem(&1, 0))
      %Valley{ valley |
        blizzards: blizzards,
        positions: positions
      }
    end

    defp move_blizzards(%Valley{ size: { x_max, y_max }, blizzards: blizzards }) do
      for { position, direction } <- blizzards do
        new_position = case add(position, direction) do
          { 0, y } -> { x_max - 1, y }
          { ^x_max, y } -> { 1, y }
          { x, 0 } -> { x, y_max - 1 }
          { x, ^y_max } -> { x, 1 }
          new_pos -> new_pos
        end
        { new_position, direction }
      end
    end

    defp add({ x1, y1 }, { x2, y2 }), do: { x1 + x2, y1 + y2 }
  end

  defmodule Expedition do
    defstruct [:position, :start, :goal, :size, :prev, :move_to, moves: 0]
    def new(map, target) do
      { start, goal } = map
        |> Enum.filter(&is_nil(elem(&1, 1)))
        |> Enum.map(&elem(&1, 0))
        |> Enum.min_max()
      { x_max, y_max } = Enum.max(Map.keys(map))
      move_to = case target do
        :start -> start
        :goal -> goal
      end
      %Expedition{
        position: start,
        start: start,
        goal: goal,
        size: { x_max, y_max },
        move_to: move_to
      }
    end

    def change_target(expedition, target) do
      move_to = case target do
        :start -> expedition.start
        :goal -> expedition.goal
      end
      %Expedition{ expedition |
        move_to: move_to
      }
    end

    def state_key(%Expedition{ position: { x, y }, moves: moves }), do: { x, y, moves }

    def successors(expedition, occupied_spaces) do
      for next_pos <- next_positions(expedition, occupied_spaces) do
        %Expedition{ expedition |
          position: next_pos,
          moves: expedition.moves + 1,
          prev: expedition
        }
      end
    end

    def is_final?(%Expedition{ position: pos, move_to: pos }), do: true
    def is_final?(%Expedition{}), do: false

    defp next_positions(expedition, occupied_spaces) do
      %Expedition{ position: position, start: start, goal: goal, move_to: move_to, size: size } = expedition
      moves = [{ 0, 1 }, { 1, 0 }, { 0, 0 }, { -1, 0 }, { 0, -1 }]
      positions =
        for move <- moves,
            pos = add(position, move),
            is_valid_position?(pos, start, goal, size, occupied_spaces) do
          pos
        end
      Enum.sort_by(positions, &distance(&1, move_to))
    end
    defp is_valid_position?(pos, start, goal, size, occupied_spaces) do
      (pos == start or pos == goal or in_bounds?(pos, size))
        and not MapSet.member?(occupied_spaces, pos)
    end
    defp in_bounds?({ x, y }, { x_max, y_max }), do: x in 1..(x_max - 1) and y in 1..(y_max - 1)

    defp add({ x1, y1 }, { x2, y2 }), do: { x1 + x2, y1 + y2 }
    defp distance({ x1, y1 }, { x2, y2 }), do: abs(x2 - x1) + abs(y2 - y1)
  end

  def part1(input) do
    map = parse(input)
    state = Expedition.new(map, :goal)
    valleys = %{
      0 => Valley.new(map)
    }
    { _, end_state } = bfs(state, valleys)
    #print_history(end_state, valleys)
    end_state.moves
  end
  def part2(input) do
    map = parse(input)
    state = Expedition.new(map, :goal)
    valleys = %{
      0 => Valley.new(map)
    }
    { valleys, first_to_goal } = bfs(state, valleys)
    { valleys, back_to_start } = bfs(Expedition.change_target(first_to_goal, :start), valleys)
    { _, end_state } = bfs(Expedition.change_target(back_to_start, :goal), valleys)
    #print_history(end_state, valleys)
    end_state.moves
  end

  defp parse(input) do
    for { line, y } <- Enum.with_index(input),
        { char, x } <- Enum.with_index(String.codepoints(line)),
        into: %{} do
      contents = case char do
        "#" -> :wall
        "^" -> { :blizzard, { 0, -1 } }
        "v" -> { :blizzard, { 0, 1 } }
        "<" -> { :blizzard, { -1, 0 } }
        ">" -> { :blizzard, { 1, 0 } }
        "." -> nil
      end
      { { x, y }, contents }
    end
  end

  defp bfs(state, valleys), do: bfs(state, valleys, :queue.new(), MapSet.new())
  defp bfs(state, valleys, frontier, seen) do
    cond do
      Expedition.is_final?(state) -> { valleys, state }
      MapSet.member?(seen, Expedition.state_key(state)) -> bfs(valleys, frontier, seen)
      true ->
        { blizzards, valleys } = blizzards_at(valleys, state.moves + 1)
        frontier = for successor <- Expedition.successors(state, blizzards), reduce: frontier do
          f -> :queue.in(successor, f)
        end
        seen = MapSet.put(seen, Expedition.state_key(state))
        bfs(valleys, frontier, seen)
    end
  end
  defp bfs(valleys, frontier, seen) do
    { { :value, next }, frontier } = :queue.out(frontier)
    bfs(next, valleys, frontier, seen)
  end

  defp blizzards_at(valleys, moves) do
    { valley, valleys } = valley_at(valleys, moves)
    { valley.positions, valleys }
  end
  defp valley_at(valleys, moves) do
    if Map.has_key?(valleys, moves) do
      { valleys[moves], valleys }
    else
      { prev, valleys } = valley_at(valleys, moves - 1)
      valley = Valley.next(prev)
      { valley, Map.put(valleys, moves, valley) }
    end
  end

  defp history(nil), do: []
  defp history(expedition), do: [expedition | history(expedition.prev)]

  def print_history(expedition, valleys) do
    for exp <- Enum.reverse(history(expedition)) do
      { valley, _ } = valley_at(valleys, exp.moves)
      print(exp, valley)
    end
  end
  defp print(expedition, valley) do
    blizzards = Enum.group_by(valley.blizzards, &elem(&1, 0), &elem(&1, 1))
    { x_max, y_max } = expedition.size
    IO.puts("Minute #{expedition.moves}:")
    0..x_max
      |> Enum.map(fn x -> cond do
          { x, 0 } == expedition.position -> "E"
          { x, 0 } == expedition.start -> "."
          true -> "#"
        end
      end)
      |> Enum.join()
      |> IO.puts()

    for y <- 1..(y_max - 1) do
      for x <- 0..x_max do
        cond do
          x == 0 -> "#"
          x == x_max -> "#"
          { x, y } == expedition.position -> "E"
          true -> blizzard_char(blizzards[{ x, y }])
        end
      end |> Enum.join() |> IO.puts()
    end

    0..x_max
      |> Enum.map(fn x -> cond do
          { x, y_max } == expedition.position -> "E"
          { x, y_max } == expedition.goal -> "."
          true -> "#"
        end
      end)
      |> Enum.join()
      |> IO.puts()
  end

  defp blizzard_char(nil), do: "."
  defp blizzard_char([{ 0, 1 }]), do: "v"
  defp blizzard_char([{ 0, -1 }]), do: "^"
  defp blizzard_char([{ 1, 0 }]), do: ">"
  defp blizzard_char([{ -1, 0 }]), do: "<"
  defp blizzard_char(list), do: Integer.to_string(length(list))
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day24.part1(input))
IO.puts(Day24.part2(input))
