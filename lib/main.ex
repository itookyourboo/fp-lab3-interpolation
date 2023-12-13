defmodule Interpolation.Main do
  alias Interpolation.Handler.Output
  alias Interpolation.Handler.Input
  alias Interpolation.Method.Linear
  alias Interpolation.Method.Lagrange
  alias Interpolation.Method.Gauss
  alias Interpolation.Utils

  @methods %{
    "linear" => {:linear, Linear},
    "lagrange" => {:lagrange, Lagrange},
    "gauss" => {:gauss, Gauss}
  }

  def start(methods, window, frequency) do
    Utils.register_process(:output, Output.start())

    workers =
      methods
      |> Enum.filter(&Map.has_key?(@methods, &1))
      |> Enum.map(&Map.get(@methods, &1))
      |> Enum.map(fn {method, mod} ->
        Utils.register_process(method, mod.start(window, frequency))
      end)

    input_pid = Utils.register_process(:input, Input.start(workers))

    wait_for_exit(Enum.concat(workers, [input_pid]))
  end

  defp wait_for_exit(track_pids) do
    if Enum.all?(track_pids, fn pid -> Process.alive?(pid) end) do
      wait_for_exit(track_pids)
    end
  end
end
