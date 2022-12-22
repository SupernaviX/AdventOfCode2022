defmodule Day20 do
  defmodule LinkedList do
    def new(items) do
      next = tl(items) ++ [hd(items)]
      next_map = Enum.zip(items, next) |> Map.new()
      for { prev, current } <- next_map, into: %{} do
        next = next_map[current]
        { current, { prev, next} }
      end
    end

    def shift(list, item, distance) do
      distance = Integer.mod(distance, map_size(list) - 1)
      if distance == 0 do
        list
      else
        { old_before, old_after } = list[item]
        new_before = at(list, item, distance)
        new_after = if item == elem(list[new_before], 1) do
          elem(list[item], 1)
        else
          elem(list[new_before], 1)
        end
        list
          |> Map.update!(old_before, fn val -> put_elem(val, 1, old_after) end)
          |> Map.update!(old_after, fn val -> put_elem(val, 0, old_before) end)
          |> Map.update!(new_before, fn val -> put_elem(val, 1, item) end)
          |> Map.update!(new_after, fn val -> put_elem(val, 0, item) end)
          |> Map.replace(item, { new_before, new_after })
      end
    end

    def at(list, from, distance) when distance < 0 do
      Stream.iterate(from, fn current -> elem(list[current], 0) end)
        |> Enum.at(-distance)
    end
    def at(list, from, distance) do
      Stream.iterate(from, fn current -> elem(list[current], 1) end)
        |> Enum.at(distance)
    end
  end

  def part1(input) do
    items = parse(input)
    list = LinkedList.new(items)
    mixed = mix(items, list)
    get_coords_sum(items, mixed)
  end

  def part2(input) do
    items = for { item, index } <- parse(input) do
      { item * 811589153, index }
    end
    mixed = for _ <- 0..9, reduce: LinkedList.new(items) do
      list -> mix(items, list)
    end
    get_coords_sum(items, mixed)
  end

  defp parse(lines) do
    Enum.map(lines, &String.to_integer/1) |> Enum.with_index()
  end

  defp mix([], list), do: list
  defp mix([item|items], list) do
    { value, _ } = item
    shifted = LinkedList.shift(list, item, value)
    mix(items, shifted)
  end

  defp get_coords_sum(items, list) do
    zero = Enum.find(items, fn { value, _ } -> value == 0 end)
    first = LinkedList.at(list, zero, 1000)
    second = LinkedList.at(list, first, 1000)
    third = LinkedList.at(list, second, 1000)
    Enum.map([first, second, third], fn { value, _ } -> value end) |> Enum.sum()
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day20.part1(input))
IO.puts(Day20.part2(input))
