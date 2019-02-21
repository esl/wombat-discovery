defmodule WombatApiTest do
  use ExUnit.Case
  alias WombatDiscovery.AutomaticConnector
  alias WombatDiscovery.WombatApi
  import Mock

  test "When there is no connection discory_me returns :no_connection" do
    with_mocks([
      {GenServer, [],
       [
         call: fn _target, _msg, _time ->
           :erlang.exit(
             {{:nodedown, :"abc@127.0.0.1"},
              {:gen_server, :call, [{:notyet, :"abc@127.0.0.1"}, :Hello, 5000]}}
           )
         end
       ]},
      {
        WombatDiscovery.WombatApi,
        [:passthrough],
        [
          set_cookie: fn _nodename, _cookie ->
            :ok
          end
        ]
      }
    ]) do
      assert :no_connection = WombatApi.discover_me(:"wombat_test@127.0.0.1", :cookie)
    end
  end

  test "When there is connection, but no process discory_me returns :no_connection" do
    with_mocks([
      {GenServer, [],
       [
         call: fn _target, _msg, _time ->
           :erlang.exit(
             {:noproc, {:gen_server, :call, [{:notyet, :"abc@127.0.0.1"}, :Hello, 5000]}}
           )
         end
       ]},
      {
        WombatDiscovery.WombatApi,
        [:passthrough],
        [
          set_cookie: fn _nodename, _cookie ->
            :ok
          end
        ]
      }
    ]) do
      assert :no_connection = WombatApi.discover_me(:"wombat_test@127.0.0.1", :cookie)
      assert 2 = :meck.num_calls(WombatApi, :set_cookie, :_)
    end
  end
end
