defmodule Day23 do
  defmodule Grove do
    @north { 0, -1 }
    @south { 0, 1 }
    @west { -1, 0 }
    @east { 1, 0 }

    defstruct [:map, :dirs ]
    def new(map), do: %Grove{ map: map, dirs: Stream.cycle([@north, @south, @west, @east]) }

    def empty_ground(grove) do
      { x1, x2 } = Enum.map(grove.map, &elem(&1, 0)) |> Enum.min_max()
      { y1, y2 } = Enum.map(grove.map, &elem(&1, 1)) |> Enum.min_max()
      (x2 - x1 + 1) * (y2 - y1 + 1) - MapSet.size(grove.map)
    end

    def print(grove) do
      { x1, x2 } = Enum.map(grove.map, &elem(&1, 0)) |> Enum.min_max()
      { y1, y2 } = Enum.map(grove.map, &elem(&1, 1)) |> Enum.min_max()
      for y <- y1..y2 do
        line = Enum.map(
          x1..x2,
          fn x -> if MapSet.member?(grove.map, { x, y }), do: "#", else: "." end
        ) |> Enum.join()
        IO.puts(line)
      end
      { dx, dy } = Enum.at(grove.dirs, 0)
      IO.puts("next start: (#{dx}, #{dy})")
    end

    def step(grove) do
      #print(grove)
      new_map = move(grove.map, Enum.take(grove.dirs, 4))
      new_dirs = Stream.drop(grove.dirs, 1)
      %Grove{ map: new_map, dirs: new_dirs }
    end

    defp move(map, dirs) do
      for { elf, target } <- find_movers(map, dirs), reduce: map do
        map -> map |> MapSet.delete(elf) |> MapSet.put(target)
      end
    end

    defp find_movers(map, dirs) do
      find_proposals(map, dirs)
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Enum.filter(fn { _target, elves } -> length(elves) == 1 end)
        |> Enum.map(fn { target, [elf] } -> { elf, target } end)
    end

    defp find_proposals(map, dirs) do
      for elf <- map,
          neighbors = find_neighbors(elf, map),
          dir = propose_dir(dirs, neighbors),
          not is_nil(dir) do
        { add(elf, dir), elf }
      end
    end

    defp find_neighbors({ x, y }, map) do
      for nx <- -1..1,
          ny <- -1..1,
          (nx != 0 or ny != 0) and MapSet.member?(map, { x + nx, y + ny }),
          into: MapSet.new do
        { nx, ny }
      end
    end

    defp propose_dir(dirs, neighbors) do
      if not Enum.empty?(neighbors) do
        Enum.find(dirs, &can_propose_dir?(&1, neighbors))
      end
    end

    defp can_propose_dir?(dir, neighbors) do
      Enum.all?(must_be_clear(dir), fn req -> not MapSet.member?(neighbors, req) end)
    end

    defp must_be_clear(@north), do: [@north, add(@north, @east), add(@north, @west)]
    defp must_be_clear(@south), do: [@south, add(@south, @east), add(@south, @west)]
    defp must_be_clear(@west), do: [@west, add(@north, @west), add(@south, @west)]
    defp must_be_clear(@east), do: [@east, add(@north, @east), add(@south, @east)]

    defp add({ x1, y1 }, { x2, y2 }), do: { x1 + x2, y1 + y2 }
  end

  def part1(input) do
    grove = Grove.new(parse(input))
    groves = Stream.iterate(grove, &Grove.step/1)
    final_grove = Enum.at(groves, 10)
    Grove.empty_ground(final_grove)
  end

  def part2(input) do
    grove = Grove.new(parse(input))
    groves = Stream.iterate(grove, &Grove.step/1)
    { _, step } = Stream.zip(groves, Stream.drop(groves, 1))
      |> Stream.with_index(1)
      |> Enum.find(fn { { prev, next }, _ } -> prev.map == next.map end)
    step
  end

  defp parse(input) do
    for { line, y } <- Enum.with_index(input),
        { "#", x } <- Enum.with_index(String.codepoints(line)),
        into: MapSet.new() do
      { x, y }
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day23.part1(input))
IO.puts(Day23.part2(input))
