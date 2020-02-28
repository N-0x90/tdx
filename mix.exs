defmodule Tdx.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :tdx,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Tdx",
      description: "TDS driver for Elixir - SSH",
      source_url: "https://github.com/N-0x90/tdx",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Tdx.App, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_connection, "~> 2.1"},
      {:decimal, "~> 1.6"},
    ]
  end
end
