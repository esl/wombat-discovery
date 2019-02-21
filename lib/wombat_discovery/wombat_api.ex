defmodule WombatDiscovery.WombatApi do
  @discover_timeout 15000

  @spec discover_me(atom(), atom()) :: :ok | {:error, atom(), String.t()} | :no_connection
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
      WombatDiscovery.WombatApi.set_cookie(nodename, target_cookie)
    end
  end

  @spec set_cookie(atom(), atom()) :: true
  def set_cookie(nodename, cookie) do
    :erlang.set_cookie(nodename, cookie)
  end
end
