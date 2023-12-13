defmodule Interpolation.Method.Linear do
  alias Interpolation.Utils

  @method_name "Linear interpolation"
  @window_size 2

  def start(_window, frequency, output_pid) do
    spawn(fn ->
      loop({@window_size, frequency, [], output_pid})
    end)
  end

  defp interpolate(frequency, [[x1, y1], [x2, y2]]) do
    k = (y2 - y1) / (x2 - x1)
    b = y1 - k * x1

    xs = Utils.float_range(x1, x2, frequency)
    ys = Enum.map(xs, fn x -> k * x + b end)

    [xs, ys]
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
