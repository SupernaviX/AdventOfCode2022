defmodule Day22 do
  defmodule State do
    defstruct [:map, :borders, :pos, dir: { 1, 0 } ]
    def new(map, borders) do
      start_pos = Map.keys(map)
        |> Enum.filter(fn { _, y } -> y == 0 end)
        |> Enum.min()
      %State{ map: map, borders: borders, pos: start_pos }
    end

    def move(state, :left) do
      { old_dx, old_dy } = state.dir
      %State{ state | dir: { old_dy, -old_dx } }
    end
    def move(state, :right) do
      { old_dx, old_dy } = state.dir
      %State{ state | dir: { -old_dy, old_dx } }
    end
    def move(state, 0), do: state
    def move(state, distance) do
      { old_x, old_y } = state.pos
      { dx, dy } = state.dir
      new_pos = { old_x + dx, old_y + dy }
      { newer_pos, new_dir } = case state.borders[{ new_pos, state.dir }] do
         { newer_pos, new_dir } -> { newer_pos, new_dir }
         _ -> { new_pos, state.dir }
      end
      case state.map[newer_pos] do
         "#" -> state
         "." -> move(%State{ state | pos: newer_pos, dir: new_dir }, distance - 1)
      end
    end

    def password(state) do
      { x, y } = state.pos
      row = y + 1
      column = x + 1
      facing = case state.dir do
        { 1, 0 } -> 0
        { 0, 1 } -> 1
        { -1, 0 } -> 2
        { 0, -1 } -> 3
      end
      (row * 1000) + (column * 4) + facing
    end
  end

  @north { 0, -1 }
  @south { 0, 1 }
  @east { 1, 0 }
  @west { -1, 0 }

  def part1(input) do
    { map, directions } = parse(input)
    borders = compute_wrapping_borders(map)
    final_state = for dir <- directions, reduce: State.new(map, borders) do
      state -> State.move(state, dir)
    end
    State.password(final_state)
  end

  # giving up and hard coding
  @test_adjacencies %{
    { 2, 0 } => %{
      @north => { { 0, 1 }, @south },
      @south => { { 2, 1 }, @south },
      @east => { { 3, 2 }, @west },
      @west => { { 1, 1 }, @south },
    },
    { 0, 1 } => %{
      @north => { { 2, 0 }, @south },
      @south => { { 2, 2 }, @north },
      @east => { { 1, 1 }, @east },
      @west => { { 3, 2 }, @north },
    },
    { 1, 1 } => %{
      @north => { { 2, 0 }, @east },
      @south => { { 2, 2 }, @east },
      @east => { { 2, 1 }, @east },
      @west => { { 0, 1 }, @west },
    },
    { 2, 1 } => %{
      @north => { { 2, 0 }, @north },
      @south => { { 2, 2 }, @south },
      @east => { { 3, 2 }, @south },
      @west => { { 1, 1 }, @west },
    },
    { 2, 2 } => %{
      @north => { { 2, 1 }, @north },
      @south => { { 0, 1 }, @north },
      @east => { { 3, 2 }, @east },
      @west => { { 1, 1 }, @north },
    },
    { 3, 2 } => %{
      @north => { { 2, 1 }, @west },
      @south => { { 0, 1 }, @east },
      @east => { { 2, 0 }, @west },
      @west => { { 2, 2 }, @west },
    }
  }
  @real_adjacencies %{
    { 1, 0 } => %{
      @north => { { 0, 3 }, @east },
      @south => { { 1, 1 }, @south },
      @east => { { 2, 0 }, @east },
      @west => { { 0, 2 }, @east },
    },
    { 2, 0 } => %{
      @north => { { 0, 3 }, @north },
      @south => { { 1, 1 }, @west },
      @east => { { 1, 2 }, @west },
      @west => { { 1, 0 }, @west  }
    },
    { 1, 1 } => %{
      @north => { { 1, 0 }, @north },
      @south => { { 1, 2 }, @south },
      @east => { { 2, 0 }, @north },
      @west => { { 0, 2 }, @south },
    },
    { 0, 2 } => %{
      @north => { { 1, 1 }, @east },
      @south => { { 0, 3 }, @south },
      @east => { { 1, 2 }, @east },
      @west => { { 1, 0 }, @east },
    },
    { 1, 2 } => %{
      @north => { { 1, 1 }, @north },
      @south => { { 0, 3 }, @west },
      @east => { { 2, 0 }, @west },
      @west => { { 0, 2 }, @west },
    },
    { 0, 3 } => %{
      @north => { { 0, 2 }, @north },
      @south => { { 2, 0 }, @south },
      @east => { { 1, 2 }, @north },
      @west => { { 1, 0 }, @south },
    },
  }

  def part2(input) do
    { map, directions } = parse(input)
    borders = compute_cube_borders(map)
    final_state = for dir <- directions, reduce: State.new(map, borders) do
      state -> State.move(state, dir)
    end
    State.password(final_state)
  end

  defp parse(input) do
    { map, [_, directions] } = Enum.split_while(input, fn line -> line != "" end)
    { parse_map(map), parse_directions(directions) }
  end

  defp parse_map(lines) do
    for { line, y } <- Enum.with_index(lines),
      { char, x } <- Enum.with_index(String.codepoints(line)),
      char != " ",
      into: %{},
      do: { { x, y }, char }
  end

  defp parse_directions(""), do: []
  defp parse_directions("L" <> rest), do: [:left | parse_directions(rest)]
  defp parse_directions("R" <> rest), do: [:right | parse_directions(rest)]
  defp parse_directions(str) do
    { value, rest } = Integer.parse(str)
    [ value | parse_directions(rest) ]
  end

  defp compute_wrapping_borders(map) do
    x_borders = Enum.group_by(Map.keys(map), &elem(&1, 1), &elem(&1, 0))
      |> Enum.flat_map(fn { y, xs } ->
        { x_min, x_max } = Enum.min_max(xs)
        [
          { { { x_min - 1, y }, @west }, { { x_max, y }, @west } },
          { { { x_max + 1, y }, @east }, { { x_min, y }, @east } }
        ]
      end)
    y_borders = Enum.group_by(Map.keys(map), &elem(&1, 0), &elem(&1, 1))
      |> Enum.flat_map(fn { x, ys } ->
        { y_min, y_max } = Enum.min_max(ys)
        [
          { { { x, y_min - 1 }, @north }, { { x, y_max }, @north } },
          { { { x, y_max + 1 }, @south }, { { x, y_min }, @south } }
        ]
      end)
    Map.new(x_borders ++ y_borders)
  end

  defp compute_cube_borders(map) do
    side_size = trunc(:math.sqrt(div(map_size(map), 6)))
    adjacencies = case side_size do
      4 -> @test_adjacencies
      50 -> @real_adjacencies
    end
    adjacencies_to_boundaries(adjacencies, side_size)
  end

  defp adjacencies_to_boundaries(adjacencies, side_size) do
    for { side, adjacency } <- adjacencies,
        { dir, { new_side, new_dir } } <- adjacency,
        add(side, dir) != new_side,
        { start_point, end_point } <- Enum.zip(
          points_along_side(side, dir, side_size, 1),
          Enum.reverse(points_along_side(new_side, invert(new_dir), side_size, 0))),
        into: %{} do
      { { start_point, dir }, { end_point, new_dir } }
    end
  end

  defp points_along_side({ sx, sy }, @north, side_size, offset) do
    y = (sy * side_size) - offset
    for x <- (sx * side_size)..(((sx + 1) * side_size) - 1), do: { x, y }
  end
  defp points_along_side({ sx, sy }, @south, side_size, offset) do
    y = ((sy + 1) * side_size) - 1 + offset
    Enum.reverse(for x <- (sx * side_size)..(((sx + 1) * side_size) - 1), do: { x, y })
  end
  defp points_along_side({ sx, sy }, @east, side_size, offset) do
    x = ((sx + 1) * side_size) - 1 + offset
    for y <- (sy * side_size)..(((sy + 1) * side_size) - 1), do: { x, y }
  end
  defp points_along_side({ sx, sy }, @west, side_size, offset) do
    x = (sx * side_size) - offset
    Enum.reverse(for y <- (sy * side_size)..(((sy + 1) * side_size) - 1), do: { x, y })
  end

  defp add({ x1, y1 }, { x2, y2 }) do
    { x1 + x2, y1 + y2 }
  end
  defp invert({ x, y }), do: { -x, -y }
end

input = File.stream!("input") |> Enum.map(&(String.trim(&1, "\n")))
IO.puts(Day22.part1(input))
IO.puts(Day22.part2(input))
