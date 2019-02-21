defmodule TestApp do
  use Application

  @moduledoc """
  Documentation for TestApp.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TestApp.hello()
      :world

  """
  def start(_type, _args) do
    IO.inspect("Starting application...")
    TestSupervisor.start_link(name: MySupervisor)
  end

  def stop(_state) do
    IO.inspect("Stopping")
  end
end
