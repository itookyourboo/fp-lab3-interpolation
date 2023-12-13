defmodule Interpolation.Method.Gauss do
  alias Interpolation.Utils
  alias Interpolation.Matrix

  @method_name "Gauss interpolation"

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

    ys = Enum.map(xs, &gauss_polynomial(points, &1))

    [xs, ys]
  end

  defp gauss_polynomial(points, x) do
    n = length(points)

    matrix =
      Enum.reduce(0..(n - 1), Matrix.new(n, n), fn i, acc ->
        Matrix.set(acc, i, 0, get_y(points, i))
      end)

    matrix =
      Enum.reduce(1..(n - 1), matrix, fn i, i_acc ->
        Enum.reduce(0..(n - 2), i_acc, fn j, j_acc ->
          Matrix.set(j_acc, j, i, Matrix.elem(j_acc, j + 1, i - 1) - Matrix.elem(j_acc, j, i - 1))
        end)
      end)

    base = Matrix.elem(matrix, div(n, 2), 0)
    t = (x - get_x(points, div(n, 2))) / (get_x(points, 1) - get_x(points, 0))

    result =
      Enum.reduce(1..(n - 1), 0, fn i, acc ->
        acc + gauss_t(t, i) * Matrix.elem(matrix, div(n - i, 2), i) / factorial(i)
      end)

    base + result
  end

  defp factorial(x) when x > 1, do: x * factorial(x - 1)
  defp factorial(_), do: 1

  defp get_x(points, i) do
    Enum.at(points, i) |> Enum.at(0)
  end

  defp get_y(points, i) do
    Enum.at(points, i) |> Enum.at(1)
  end

  defp gauss_t(t, 1), do: t

  defp gauss_t(t, n) do
    Enum.reduce(1..(n - 1), t, fn i, acc ->
      acc * (t + -1 ** i * div(i + 1, 2))
    end)
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
