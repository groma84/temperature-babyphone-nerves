defmodule MicrophoneDigital do
  require Logger

  use GenServer

  alias Circuits.GPIO

  @mic_digital_input_pin Application.get_env(:temperature_babyphone, :mic_digital_input_pin, 17)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(__MODULE__, :noargs)
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, input_gpio} = GPIO.open(@mic_digital_input_pin, :input)

    self() |> send(:subscribe_to_changes)

    {:ok, %{pin: input_gpio}}
  end

  @impl true
  def handle_info(:subscribe_to_changes, %{pin: pin} = state) do
    GPIO.set_interrupts(pin, :both)
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 0}, state) do
    Logger.info("Received low on mic digital")

    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 1}, state) do
    Logger.info("Received high on mic digital")

    {:noreply, state}
  end
end
