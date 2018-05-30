defmodule Nox.Brunch do
  @moduledoc """
  brunch wrapper
  """
  use Nox.Bin, name: "brunch"

  @doc false
  def do_version(binpath) do
    with {semver, 0} <- System.cmd(binpath, ["--version"]) do
      String.trim(semver)
    else _ -> :error
    end
  end
end
