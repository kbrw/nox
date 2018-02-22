defmodule NodexTest do
  use ExUnit.Case
  doctest Nodex

  test "Check node version" do
    assert match?( {8, 9, _, _}, Nodex.Node.version() )
  end

  test "Check npm version" do
    assert match?( {5, 6, _, _}, Nodex.Npm.version() )
  end
end
