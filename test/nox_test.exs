defmodule NoxTest do
  use ExUnit.Case
  doctest Nox

  test "Check node version" do
    assert match?( {8, 9, _, _}, Nox.Node.version() )
  end

  test "Check npm version" do
    assert match?( {5, 6, _, _}, Nox.Npm.version() )
  end
end
