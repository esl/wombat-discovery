defmodule WombatDiscovery.Supervisor do
  use Supervisor

  alias WombatDiscovery.AutomaticConnector

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(AutomaticConnector, [[discovery_config: WombatDiscovery.Application.load_config()]] )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
