defmodule Interpolation.Method.Linear do
  alias Interpolation.Utils

  @method_name "Linear interpolation"
  @window_size 2

  def start(_window, frequency) do
    spawn(fn -> loop(state(frequency)) end)
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

  defp process_message({:new_point, point, _}, {frequency, points}) do
    points = Utils.push_point(points, point, @window_size)

    if length(points) == @window_size do
      send(:output, {
        :result,
        {@method_name, interpolate(frequency, points)},
        self()
      })
    end

    state(frequency, points)
  end

  defp process_message({:stop, _, _}, _) do
    System.stop()
  end

  defp process_message(msg, state) do
    Utils.log_unexpected_message(msg)

    state
  end

  defp state(frequency, points \\ []), do: {frequency, points}
end
