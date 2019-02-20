defmodule WombatDiscovery.Application do
  use Application
  alias WombatDiscovery.Supervisor

  def start(_type, _args) do
    Supervisor.start_link(name: Supervisor)
  end

  def load_config() do
    sys_nodename = System.get_env("WOMBAT_NODENAME")
    sys_cookie = System.get_env("WOMBAT_COOKIE")

    app_nodename = Application.get_env(:wombat_discovery, :wombat_nodename)
    app_cookie = Application.get_env(:wombat_discovery, :wombat_cookie, :wombat)

    retry_count = Application.get_env(:wombat_discovery, :retry_count, 20)
    retry_wait = Application.get_env(:wombat_discovery, :retry_wait, 30000)

    case [{sys_nodename, sys_cookie}, {app_nodename, app_cookie}] do
      [{nil, nil}, {nil, _}] ->
        :no_config

      [{sys_nodename, sys_cookie}, _] when not is_nil(sys_nodename) ->
        sys_not_nil_cookie =
          case sys_cookie do
            nil -> :wombat
            _ -> String.to_atom(sys_cookie)
          end

        %{
          :wombat_nodename => String.to_atom(sys_nodename),
          :wombat_cookie => sys_not_nil_cookie,
          :retry_count => retry_count,
          :retry_wait => retry_wait
        }

      [_, {app_nodename, app_cookie}]
      when not is_nil(app_nodename) and
             not is_nil(app_cookie) ->
        %{
          :wombat_nodename => app_nodename,
          :wombat_cookie => app_cookie,
          :retry_count => retry_count,
          :retry_wait => retry_wait
        }
    end
  end
end
