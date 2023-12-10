defmodule Interpolation.Handler.Input do
  @input_handler :line

  def start(listener) do
    spawn(fn -> loop(listener) end)
  end

  defp loop(listener) do
    case @input_handler do
      :line -> line_handler(listener)
      :stream -> stream_handler(listener)
    end
  end

  defp line_handler(listener) do
    line = IO.gets("")
    process_line(line, listener)

    if line != :eof do
      line_handler(listener)
    end
  end

  defp stream_handler(listener) do
    IO.stream()
    |> Stream.each(&process_line(&1, listener))
    |> Stream.run()
  end

  defp process_line(:eof, listener) do
    send(listener, {:stop, nil, self()})
  end

  defp process_line(line, listener) do
    point = line_to_point(line)
    send(listener, {:new_point, point, self()})
  end

  defp line_to_point(line) do
    line
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&Float.parse/1)
    |> Enum.map(&elem(&1, 0))
  end
end
