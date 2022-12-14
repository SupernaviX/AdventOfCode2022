defmodule Day11 do
  defmodule Monkey do
    defstruct(
      items: [],
      operation: nil,
      test: 0,
      true_target: 0,
      false_target: 0,
      inspected: 0
    )
    def inspect_items(monkey, relief_factor) do
      items = Enum.map(monkey.items, fn worry ->
        worry = div(monkey.operation.(worry), relief_factor)
        target = choose_target(monkey, worry)
        { target, worry }
      end)
      inspected = monkey.inspected + length(items)
      { %Monkey{monkey | items: [], inspected: inspected }, items }
    end
    defp choose_target(monkey, item) do
      if (rem(item, monkey.test) == 0) do
        monkey.true_target
      else
        monkey.false_target
      end
    end

    def catch_items(items, monkeys) do
      monkeys = Enum.reduce(items, monkeys, &catch_item/2)
      reduce_items(monkeys)
    end
    defp catch_item({ idx, item }, monkeys) do
      target = elem(monkeys, idx)
      put_elem(monkeys, idx, %Monkey{ target | items: target.items ++ [item]})
    end

    defp reduce_items(monkeys) do
      common_factor = Tuple.to_list(monkeys)
        |> Enum.map(fn monkey -> monkey.test end)
        |> Enum.product()
      Tuple.to_list(monkeys)
        |> Enum.map(&(reduce_items(&1, common_factor)))
        |> List.to_tuple()
    end
    defp reduce_items(monkey, common_factor) do
      items = monkey.items |> Enum.map(&(rem(&1, common_factor)))
      %Monkey{ monkey | items: items }
    end

    def score(monkeys) do
      Tuple.to_list(monkeys)
        |> Enum.map(fn monkey -> monkey.inspected end)
        |> Enum.sort(&(&1 >= &2))
        |> Enum.take(2)
        |> Enum.product()
    end

    def print(monkeys) do
      Enum.each(Tuple.to_list(monkeys), fn monkey -> IO.inspect(monkey.items, charlists: :as_lists) end)
    end
  end
  def part1(input) do
    monkeys = parse_monkeys(input)
    monkeys = do_rounds(monkeys, 3, 20)
    Monkey.score(monkeys)
  end

  def part2(input) do
    monkeys = parse_monkeys(input)
    monkeys = do_rounds(monkeys, 1, 10000)
    Monkey.score(monkeys)
  end

  defp do_rounds(monkeys, _, 0) do monkeys end
  defp do_rounds(monkeys, worry_factor, rounds) do
    result = do_round(monkeys, worry_factor)
    do_rounds(result, worry_factor, rounds - 1)
  end

  defp do_round(monkeys, worry_factor) do do_round(monkeys, worry_factor, tuple_size(monkeys)) end
  defp do_round(monkeys, _, 0) do monkeys end
  defp do_round(monkeys, worry_factor, turn) do
    monkey_idx = tuple_size(monkeys) - turn
    monkey = elem(monkeys, monkey_idx)

    { monkey, items } = Monkey.inspect_items(monkey, worry_factor)
    monkeys = put_elem(monkeys, monkey_idx, monkey)
    monkeys = Monkey.catch_items(items, monkeys)

    do_round(monkeys, worry_factor, turn - 1)
  end

  defp parse_monkeys(input) do
    input
      |> Enum.drop_every(7)
      |> Enum.chunk_every(6)
      |> Enum.map(&parse_monkey/1)
      |> List.to_tuple()
  end

  defp parse_monkey(lines) do
    [
      "Starting items: " <> items_str,
      "Operation: new = old " <> operation_str,
      "Test: divisible by " <> condition_str,
      "If true: throw to monkey " <> true_str,
      "If false: throw to monkey " <> false_str,
    ] = Enum.take(lines, 5)
    items = String.split(items_str, ",") |> Enum.map(&(String.to_integer(String.trim(&1))))
    operation = case operation_str do
       "* old" -> &(&1 * &1)
       "+ " <> amount -> &(&1 + String.to_integer(amount))
       "* " <> amount -> &(&1 * String.to_integer(amount))
    end
    test = String.to_integer(condition_str)
    true_target = String.to_integer(true_str)
    false_target = String.to_integer(false_str)
    #test = &(if (rem(&1, condition_val) == 0) do true_val else false_val end)
    #IO.inspect({ items, operation, test }, charlists: :as_lists)
    %Monkey{ items: items, operation: operation, test: test, true_target: true_target, false_target: false_target }
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day11.part1(input))
IO.puts(Day11.part2(input))
