defmodule WombatTest do
  use ExUnit.Case
  doctest Wombat

  test "greets the world" do
    assert Wombat.hello() == :world
  end
end
