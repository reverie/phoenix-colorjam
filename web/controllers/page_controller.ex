defmodule MyFirstChannel.PageController do
  use MyFirstChannel.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
