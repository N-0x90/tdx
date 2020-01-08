defmodule Tdx.App do
  @moduledoc false
  use Application

  def start(_, _) do
    opts = [strategy: :one_for_one, name: Tdx.Supervisor]

    children = [
      #{Tdx.TypeSupervisor, :manager},
      Tdx.Parameters
    ]

    Supervisor.start_link(children, opts)
  end
end