defmodule AutomaticConnectorTest do
  use ExUnit.Case
  alias WombatDiscovery.AutomaticConnector
  alias WombatDiscovery.WombatApi
  import Mock

  def wait_for(fun) do
    :timer.sleep(500)
    fun.()
  end

  test "When Connector is started, calls Wombat API to discover node" do
    with_mock(WombatApi,
      discover_me: fn _node, _cookie -> :ok end
    ) do
      start_supervised!(
        {AutomaticConnector,
         [
           discovery_config: %{
             :wombat_nodename => :"wombat@wombat.host",
             :wombat_cookie => :my_cookie,
             :retry_count => 5,
             :retry_wait => 10
           }
         ]}
      )

      wait_for(fn ->
        assert_called(WombatApi.discover_me(:"wombat@wombat.host", :my_cookie))
      end)
    end
  end

  test "When called with no config, doesn't call discover me" do
    with_mock(WombatApi,
      discover_me: fn _node, _cookie -> :erlang.error(:no_calls) end
    ) do
      pid =
        start_supervised!(
          {AutomaticConnector,
           [
             discovery_config: :no_config
           ]}
        )

      wait_for(fn ->
        assert :erlang.is_process_alive(pid)
        assert not called(WombatApi.discover_me(:_, :_))
      end)
    end
  end

  test "When wombat is not available retry connection" do
    with_mock(WombatApi,
      discover_me: fn _node, _cookie ->
        :no_connection
      end
    ) do
      start_supervised!(
        {AutomaticConnector,
         [
           discovery_config: %{
             :wombat_nodename => :"wombat@wombat.host",
             :wombat_cookie => :my_cookie,
             :retry_count => 5,
             :retry_wait => 10
           }
         ]}
      )

      wait_for(fn ->
        assert 6 = :meck.num_calls(WombatApi, :discover_me, :_)

        assert_called(WombatApi.discover_me(:"wombat@wombat.host", :my_cookie))
      end)
    end
  end
end
