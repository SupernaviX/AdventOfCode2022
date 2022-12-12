defmodule Day8 do
  def part1(input) do
    rows = parse(input)
    addressed_rows = attach_addresses(rows)
    seen = MapSet.new()
    seen = addressed_rows |> Enum.reduce(seen, &acc_seen/2)
    seen = addressed_rows |> Enum.map(&Enum.reverse/1) |> Enum.reduce(seen, &acc_seen/2)
    addressed_cols = transpose(addressed_rows)
    seen = addressed_cols |> Enum.reduce(seen, &acc_seen/2)
    seen = addressed_cols |> Enum.map(&Enum.reverse/1) |> Enum.reduce(seen, &acc_seen/2)
    MapSet.size(seen)
  end

  def part2(input) do
    rows = parse(input)
    addressed_rows = attach_addresses(rows)
    scores = initialize_score_map(addressed_rows, 1)
    scores = Enum.reduce(addressed_rows, scores, &acc_distance/2)
    scores = Enum.reduce(Enum.map(addressed_rows, &Enum.reverse/1), scores, &acc_distance/2)
    addressed_cols = transpose(addressed_rows)
    scores = Enum.reduce(addressed_cols, scores, &acc_distance/2)
    scores = Enum.reduce(Enum.map(addressed_cols, &Enum.reverse/1), scores, &acc_distance/2)
    Enum.map(scores, fn { _, val } -> val end) |> Enum.max()
  end

  defp acc_seen(row, seen) do
    { seen, _ } = row |> Enum.reduce({ seen, -1 }, &acc_seen_so_far/2)
    seen
  end

  defp acc_seen_so_far({ height, address }, { seen, max }) do
    if (height > max) do
      { MapSet.put(seen, address), height }
    else
      { seen, max }
    end
  end

  defp acc_distance(row, scores) do
    { done, wip } = Enum.reduce(row, { [], [] }, &acc_distance_so_far/2)
    index_scores = Enum.map(wip, fn ({ _, index, score }) -> { index, score } end) ++ done
    Enum.reduce(index_scores, scores, fn ({ index, score }, s) -> Map.update!(s, index, &(&1 * score)) end)
  end
  defp acc_distance_so_far({ height, index }, { done, wip }) do
    { now_done, still_wip } = Enum.reduce(wip, { done, [] }, fn({ h, i, s }, { ds, ws }) ->
      if (h <= height) do
        { [{ i, s + 1 } | ds], ws}
      else
        { ds, [{ h, i, s + 1 } | ws]}
      end
    end)
    { now_done, [{ height, index, 0 } | still_wip] }
  end

  defp parse(input) do
    input |> Enum.map(&parse_line/1)
  end
  defp parse_line(line) do
    String.trim(line) |> String.codepoints() |> Enum.map(&String.to_integer/1)
  end
  defp transpose(items) do
    items |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
  end
  defp attach_addresses(rows) do
    Enum.with_index(rows)
      |> Enum.map(fn { row, y } ->
        Enum.with_index(row) |> Enum.map(fn { cell, x } -> { cell, { x, y } } end)
      end)
  end
  defp initialize_score_map(addressed_rows, default) do
    addressed_rows
      |> Enum.flat_map(fn row -> row |> Enum.map(fn { _, address } -> { address, default } end) end)
      |> Map.new()
  end
end

input = File.stream!("input")
IO.puts(Day8.part1(input))
IO.puts(Day8.part2(input))
