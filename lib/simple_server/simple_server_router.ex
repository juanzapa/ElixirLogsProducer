defmodule SimpleServer.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
plug(Plug.Logger, log: :debug)

plug(:match)

plug(:dispatch)

get "/logs" do
  conn = put_resp_header(conn, "content-type", "text/event-stream")
  conn = send_chunked(conn, 200)
  giveMeLogs(conn)
end

defp send_message(conn, message) do
  chunk(conn, "#{message}\"}\n\n")
end

def giveMeLogs(conn) do
  path_json = File.cwd! <> "/priv/input.txt"
  stream = File.stream!(path_json)
  lista= Enum.to_list(stream)
  readList(lista, 0,conn)
end

def readList(lista,pos,conn) do
  longitud=length(lista)
  cond do
    pos==longitud-1 ->
      Logger.info("terminó")
    pos<longitud-1 ->
      Logger.info(Enum.at(lista,pos))
      send_message(conn, Enum.at(lista,pos))
      :timer.sleep(1000)
      readList(lista, pos+1,conn)
  end
end
end
