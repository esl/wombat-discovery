defmodule Wombat.Application do

  use Application

  def start(_type, _args) do
    WombatSupervisor.start_link(name: WombatSupervisor)
  end
end