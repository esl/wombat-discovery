defmodule WombatDiscovery.WombatApi do
  @discover_timeout 15000

  def discover_me(nodename, cookie) do
    WombatDiscovery.WombatApi.set_cookie(nodename, cookie)
    target_cookie = Node.get_cookie()
    target_node = Node.self()
    target = {:wo_discover_dynamic_nodes, nodename}

    try do
      GenServer.call(target, {:auto_discover_node, target_node, target_cookie}, @discover_timeout)
    catch
      :exit, {{:nodedown, _}, _} -> :no_connection
      :exit, {:noproc, _} -> :no_connection
    after
      WombatDiscovery.WombatApi.set_cookie(nodename,target_cookie)
    end
  end

  def set_cookie(nodename, cookie) do
    :erlang.set_cookie(nodename, cookie)
  end
end
