defmodule NoxTest do
  use ExUnit.Case
  doctest Nox

  test "Check node version" do
    assert match?( {8, 9, _, _}, Nox.Semver.parse(Nox.Node.version(Nox.Env.default())) )
  end

  test "Check npm version" do
    assert match?( {5, 6, _, _}, Nox.Semver.parse(Nox.Npm.version(Nox.Env.default())) )
  end
end
