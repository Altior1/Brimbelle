defmodule BrimbelleWeb.PageController do
  use BrimbelleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
