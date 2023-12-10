defmodule Interpolation.Handler.Processing do
  alias Interpolation.Method.Linear
  alias Interpolation.Method.Lagrange
  alias Interpolation.Method.Gauss

  alias Interpolation.Utils

  @methods %{
    "linear" => {:linear, Linear},
    "lagrange" => {:lagrange, Lagrange},
    "gauss" => {:gauss, Gauss}
  }

  def start(methods, window, frequency, listener) do
    workers =
      methods
      |> Enum.filter(&Map.has_key?(@methods, &1))
      |> Enum.map(&Map.get(@methods, &1))

    Enum.each(workers, fn {method, mod} ->
      Utils.register_process(method, mod.start(window, frequency))
    end)

    pids = Enum.map(workers, &elem(&1, 0))

    spawn(fn -> loop(listener, pids) end)
  end

  defp loop(listener, pids) do
    receive do
      message -> process_message(message, listener, pids)
    end

    loop(listener, pids)
  end

  defp process_message({:process_point, msg, _}, _, pids) do
    Enum.each(pids, &send(&1, {:process_point, msg, self()}))
  end

  defp process_message({:result, msg, _}, listener, _) do
    send(listener, {:result, msg, self()})
  end

  defp process_message(msg, _, _) do
    Utils.log_unexpected_message(msg)
  end
end
