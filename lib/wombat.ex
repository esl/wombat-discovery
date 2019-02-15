defmodule Wombat do

  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: Wombat)
  end

  def init(_) do
    {:ok, connect()}
  end

  defp connect do
    Application.get_env(:my, :title)
    wombatnode = System.get_env("WOMBAT_NODE")
    wombatnode = 
      case wombatnode do
        nil -> 
          IO.puts "Please assign a value to the env variable WOMBAT_NODE"
        _ -> 
          :erlang.set_cookie(String.to_atom(wombatnode), :wombat)
          add_node(wombatnode)
          IO.puts "Node added"
      end
  end

  defp add_node(wombatnode) do
    cookie = Node.get_cookie()
    node = Node.self()
    send({:wo_discover_dynamic_nodes, String.to_atom(wombatnode)},
    {:auto_discover_node, node, cookie})
  end
end