defmodule Interpolation.Main do
  alias Interpolation.Handler.Output
  alias Interpolation.Handler.Input
  alias Interpolation.Method.Linear
  alias Interpolation.Method.Lagrange
  alias Interpolation.Method.Gauss
  alias Interpolation.Utils

  @methods %{
    "linear" => Linear,
    "lagrange" => Lagrange,
    "gauss" => Gauss
  }

  def start(methods, window, frequency) do
    output_pid = Utils.register_process(Output.start())

    workers =
      methods
      |> Enum.filter(&Map.has_key?(@methods, &1))
      |> Enum.map(&Map.get(@methods, &1))
      |> Enum.map(&Utils.register_process(&1.start(window, frequency, output_pid)))

    input_pid = Utils.register_process(Input.start(workers))

    wait_for_exit(Enum.concat(workers, [input_pid]))
  end

  defp wait_for_exit(track_pids) do
    if Enum.any?(track_pids, fn pid -> Process.alive?(pid) end) do
      wait_for_exit(track_pids)
    end
  end
end
