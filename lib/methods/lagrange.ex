defmodule Interpolation.Method.Lagrange do
  alias Interpolation.Utils

  @method_name "Lagrange interpolation"

  def start(window, frequency) do
    spawn(fn -> loop(state(window, frequency)) end)
  end

  defp interpolate(frequency, points) do
    xs =
      Utils.float_range(
        List.first(points) |> Enum.at(0),
        List.last(points) |> Enum.at(0),
        frequency
      )

    ys = Enum.map(xs, &lagrange_polynomial(points, &1))

    [xs, ys]
  end

  defp lagrange_polynomial(points, x) do
    xs = points |> Enum.map(&Enum.at(&1, 0))

    points
    |> Enum.with_index()
    |> Enum.map(fn {[xi, y], i} ->
      y *
        diff_prod(x, List.delete_at(xs, i)) /
        diff_prod(xi, List.delete_at(xs, i))
    end)
    |> Enum.reduce(&(&1 + &2))
  end

  defp diff_prod(x, xs) do
    xs
    |> Enum.map(&(x - &1))
    |> Enum.reduce(&(&1 * &2))
  end

  defp loop(state) do
    new_state =
      receive do
        message -> process_message(message, state)
      end

    loop(new_state)
  end

  defp process_message({:process_point, point, sender}, {window, frequency, points}) do
    points = Utils.push_point(points, point, window)

    if length(points) == window do
      send(sender, {:result, {@method_name, interpolate(frequency, points)}, self()})
    end

    state(window, frequency, points)
  end

  defp process_message(msg, state) do
    Utils.log_unexpected_message(msg)

    state
  end

  defp state(window, frequency, points \\ []), do: {window, frequency, points}
end
