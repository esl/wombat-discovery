defmodule TestSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    children = []

    IO.inspect("Supervisor started...")

    Supervisor.init(children, strategy: :one_for_one)
  end

  def test_proc() do
    IO.inspect("Test process started")

    receive do
      :stop -> :ok
    end
  end
end
