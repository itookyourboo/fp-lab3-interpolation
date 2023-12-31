defmodule Interpolation.Method.Lagrange do
  alias Interpolation.Utils

  @method_name "Lagrange interpolation"

  def start(window, frequency, output_pid) do
    spawn(fn ->
      loop({window, frequency, [], output_pid})
    end)
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

  defp process_message({:new_point, point, _}, {window, frequency, points, output_pid}) do
    points = Utils.push_point(points, point, window)

    if length(points) == window do
      send(output_pid, {
        :result,
        {@method_name, interpolate(frequency, points)},
        self()
      })
    end

    {window, frequency, points, output_pid}
  end

  defp process_message({:stop, _, _}, _) do
    Process.exit(self(), :normal)
  end

  defp process_message(msg, state) do
    Utils.log_unexpected_message(msg)

    state
  end
end
