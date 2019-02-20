defmodule ConfigLoaderTest do
  use ExUnit.Case

  setup do
    Application.delete_env(:wombat_discovery, :wombat_nodename)
    Application.delete_env(:wombat_discovery, :wombat_cookie)
    Application.delete_env(:wombat_discovery, :retry_count)
    Application.delete_env(:wombat_discovery, :retry_wait)

    System.delete_env("WOMBAT_NODENAME")
    System.delete_env("WOMBAT_COOKIE")
  end

  def load_config() do
    WombatDiscovery.Application.load_config()
  end

  test "No Config" do
    assert :no_config = load_config()
  end

  test "Erlang Env Config" do
    Application.put_env(:wombat_discovery, :wombat_nodename, :nodename)
    Application.put_env(:wombat_discovery, :wombat_cookie, :cookie)
    assert %{:wombat_nodename => :nodename, :wombat_cookie => :cookie} = load_config()
  end

  test "System Env Config" do
    System.put_env("WOMBAT_NODENAME", "nodename2")
    System.put_env("WOMBAT_COOKIE", "cookie2")
    assert %{:wombat_nodename => :nodename2, :wombat_cookie => :cookie2} = load_config()
  end

  test "If no cookie present, sys env defaults to wombat" do
    System.put_env("WOMBAT_NODENAME", "nodename3")
    assert %{:wombat_nodename => :nodename3, :wombat_cookie => :wombat} = load_config()
  end

  test "If no cookie present, app env defaults to wombat" do
    Application.put_env(:wombat_discovery, :wombat_nodename, :nodename4)
    assert %{:wombat_nodename => :nodename4, :wombat_cookie => :wombat} = load_config()
  end

  test "If app and sys env is present, sys env is the result" do
    Application.put_env(:wombat_discovery, :wombat_nodename, :nodename_app)
    Application.put_env(:wombat_discovery, :wombat_cookie, :cookie_app)
    System.put_env("WOMBAT_NODENAME", "nodename_sys")
    System.put_env("WOMBAT_COOKIE", "cookie_sys")
    assert %{:wombat_nodename => :nodename_sys, :wombat_cookie => :cookie_sys} = load_config()
  end

  test "Given no application env config for retries, when loading config, returns default retry values" do
    Application.put_env(:wombat_discovery, :wombat_nodename, :nodename_app)
    Application.put_env(:wombat_discovery, :wombat_cookie, :cookie_app)
    config = load_config()
    assert 20 = Map.get(config, :retry_count)
    assert 30000 = Map.get(config, :retry_wait)
  end

  test "Given application env config for retries, when loading config, returns from app env retry values" do
    Application.put_env(:wombat_discovery, :wombat_nodename, :nodename_app)
    Application.put_env(:wombat_discovery, :wombat_cookie, :cookie_app)
    Application.put_env(:wombat_discovery, :retry_count, 3)
    Application.put_env(:wombat_discovery, :retry_wait, 10)
    config = load_config()
    assert 3 = Map.get(config, :retry_count)
    assert 10 = Map.get(config, :retry_wait)
  end
end
