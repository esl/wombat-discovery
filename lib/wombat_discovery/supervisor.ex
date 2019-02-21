defmodule WombatDiscovery.Supervisor do
  use Supervisor

  alias WombatDiscovery.AutomaticConnector

  @spec start_link([
          {:debug, [:log | :statistics | :trace | {any(), any()}]}
          | {:hibernate_after, :infinity | non_neg_integer()}
          | {:name, atom() | {:global, any()} | {:via, atom(), any()}}
          | {:spawn_opt,
             :link
             | :monitor
             | {:fullsweep_after, non_neg_integer()}
             | {:min_bin_vheap_size, non_neg_integer()}
             | {:min_heap_size, non_neg_integer()}
             | {:priority, :high | :low | :normal}}
          | {:timeout, :infinity | non_neg_integer()}
        ]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    children = [
      worker(AutomaticConnector, [[discovery_config: WombatDiscovery.Application.load_config()]] )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
