defmodule ZhongziWeb.PageController do
  use ZhongziWeb, :controller

  def home(conn, _params) do
    # Demonstrate enhanced logging
    Zhongzi.Logger.info("Home page accessed", [
      controller: "PageController",
      action: "home",
      user_agent: get_user_agent(conn)
    ])

    # Simulate some processing time for performance logging demo
    result = Zhongzi.Logger.time_and_log("render_home_page", fn ->
      # The home page is often custom made,
      # so skip the default app layout.
      render(conn, :home, layout: false)
    end, [page: "home"])

    result
  end

  defp get_user_agent(conn) do
    case Plug.Conn.get_req_header(conn, "user-agent") do
      [user_agent | _] -> user_agent
      [] -> "unknown"
    end
  end
end
