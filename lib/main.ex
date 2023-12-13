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
    workers =
      methods
      |> Enum.filter(&Map.has_key?(@methods, &1))
      |> Enum.map(&Map.get(@methods, &1))
      |> Enum.map(fn {method, mod} ->
        Utils.register_process(method, mod.start(window, frequency))
      end)

    Utils.register_process(:input, Input.start(workers))
    Utils.register_process(:output, Output.start())

    loop()
  end

  defp loop() do
    loop()
  end
end
