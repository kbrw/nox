defmodule Nodex do
  @moduledoc """
  Wrappers for node and al. binaries
  """
  alias Nodex.Nvm

  @doc """
  Returns full path to managed executable
  """
  @spec which(String.t) :: Path.t | nil
  def which(exe) do
    case System.cmd("which", [exe], env: [{"PATH", Nvm.bindir()}]) do
      {out, 0} -> String.trim(out)
      {_, 1} -> nil
    end
  end
end
