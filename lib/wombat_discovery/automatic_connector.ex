defmodule WombatDiscovery.AutomaticConnector do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: AutomaticConnector)
  end

  @spec init(
          args :: [
            discovery_config:
              :no_config
              | %{
                  :wombat_nodename => atom(),
                  :wombat_cookie => atom(),
                  :retry_count => integer(),
                  :retry_wait => integer()
                }
          ]
        ) :: {:ok, any()}
  def init(args) do
    send(self(), :start_discovery)
    {:ok, args}
  end

  def handle_info(:start_discovery, state = [discovery_config: :no_config]) do
    log("No Wombat Discovery plugin configuration found.")
    {:noreply, state}
  end

  def handle_info(
        {:try_again, count},
        state = [
          discovery_config: %{
            :wombat_nodename => my_host,
            :wombat_cookie => my_cookie,
            :retry_wait => retry_wait
          }
        ]
      ) do
    case count do
      0 -> log("Retry count exceeded. Stopping...")
      _ -> do_discover(my_host, my_cookie, count - 1, retry_wait)
    end

    {:noreply, state}
  end

  def handle_info(:start_discovery, state) do
    case state do
      [
        discovery_config: %{
          :wombat_nodename => my_host,
          :wombat_cookie => my_cookie,
          :retry_count => retry_count,
          :retry_wait => retry_wait
        }
      ] ->
        log("Connecting to Wombat node: ~p", [my_host])
        do_discover(my_host, my_cookie, retry_count, retry_wait)

      conf ->
        IO.inspect({"invalid config", conf})
    end

    {:noreply, state}
  end

  defp do_discover(host, cookie, count, wait) do
    log("Trying to connect to ~s", [host])
    reply = WombatDiscovery.WombatApi.discover_me(host, cookie)

    case reply do
      :ok ->
        log("Node successfully added")

      {:error, :already_added, msg} ->
        log("Warning: ~s", [msg])
        log("Stopping.")

      {:error, _reason, msg} ->
        log("Error: ~s", [msg])
        log("Stopping.")

      :no_connection ->
        log("Wombat connection failed. Ensure the Wombat cookie is correct. Retrying...")
        Process.send_after(self(), {:try_again, count}, wait)
    end
  end

  defp log(msg, fmt \\ []) do
    :io.format("[WombatDiscovery] " <> msg <> "~n", fmt)
  end
end
