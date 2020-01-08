defmodule TdxTest do
  use ExUnit.Case
  doctest Tdx

  test "greets the world" do
    assert Tdx.hello() == :world
  end
end
