defmodule MicrophoneAnalog do
  use GenServer

  require Logger

  @me __MODULE__
  @min_value 0
  @max_value 250
  @change_threshold 10

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  # SERVER
  @impl true
  def init(_) do
    schedule_read()
    {:ok, %{last_value: nil}}
  end

  @impl true
  def handle_info(:read, state) do
    value = Spi.read(:channel0)

    Logger.info("Analog mic read #{value}")

    schedule_read()
    {:noreply, state}
  end

  defp schedule_read() do
    Process.send_after(self(), :read, 10_000)
  end
end
