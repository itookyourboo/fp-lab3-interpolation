defmodule Interpolation.CLI do
  @default_window_size 5
  @default_frequency 0.5

  def main(args) do
    {parsed, methods, _} =
      args
      |> OptionParser.parse(
        aliases: [
          w: :window,
          f: :frequency
        ],
        strict: [
          window: :integer,
          frequency: :float
        ]
      )

    default = [
      window: @default_window_size,
      frequency: @default_frequency
    ]

    parsed = Keyword.merge(default, parsed)

    Interpolation.Main.start(methods, parsed[:window], parsed[:frequency])
  end
end
