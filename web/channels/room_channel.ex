defmodule MyFirstChannel.RoomChannel do
  use Phoenix.Channel

  def validate_color_value(color_value) do
    true = String.to_integer(color_value) in 0..255
  end

  def set_current_color(%{"red" => red, "green" => green, "blue" => blue}) do
    # Store current color in "Redis" :D
    System.put_env("COLORJAM_COLOR", Enum.join([red, green, blue], ","))
  end

  def get_current_color() do
    colorStr = System.get_env "COLORJAM_COLOR"
    if colorStr do
      [red, green, blue] = String.split(colorStr, ",")
    else
      red = green = blue = "255"
    end
    %{red: red, green: green, blue: blue}
  end

  def join("rooms:lobby", _message, socket) do
    {:ok, get_current_color(), socket}
  end

  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", payload, socket) do
    validate_color_value(payload["red"])
    validate_color_value(payload["green"])
    validate_color_value(payload["blue"])
    set_current_color(payload)
    broadcast! socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end

