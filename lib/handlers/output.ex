defmodule Interpolation.Handler.Output do
  alias Interpolation.Utils

  def start() do
    spawn(&loop/0)
  end

  defp loop do
    receive do
      {:print, item, _} ->
        print(item)

      {:table, item, _} ->
        print_table(item)

      msg ->
        Utils.log_unexpected_message(msg)
    end

    loop()
  end

  defp print(item) do
    IO.inspect(item)
  end

  defp print_table([xs, ys]) do
    print_numbers(xs)
    print_numbers(ys)
  end

  defp print_numbers(numbers) do
    numbers
    |> Enum.map(&:erlang.float_to_binary(&1, decimals: 2))
    |> Enum.join("\t")
    |> IO.puts()
  end
end
