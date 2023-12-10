defmodule Interpolation.Main do
  alias Interpolation.Handler.Input
  alias Interpolation.Handler.Processing
  alias Interpolation.Handler.Output
  alias Interpolation.Utils

  def start(methods, window, frequency) do
    Utils.register_process(
      :input,
      Input.start(self())
    )

    Utils.register_process(
      :processing,
      Processing.start(methods, window, frequency, self())
    )

    Utils.register_process(
      :output,
      Output.start()
    )

    loop()
  end

  defp loop do
    receive do
      {:new_point, point, _} ->
        send(:processing, {:process_point, point, self()})

      {:result, {method, result}, _} ->
        send(:output, {:print, method, self()})
        send(:output, {:table, result, self()})

      {:stop, _, _} ->
        System.stop()

      msg ->
        Utils.log_unexpected_message(msg)
    end

    loop()
  end
end
