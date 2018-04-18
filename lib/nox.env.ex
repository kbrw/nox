defmodule Nox.Env do
  @moduledoc """
  Environment of node installation
  """
  alias Nox.Semver

  defstruct dir: nil, versions: []

  @default_nvm "v1.1.2"
  @default_node "8.9.4"
  @default_npm "5.6"

  @type options :: [option]
  @type option :: {:dir, Path.t}
                | {:node, String.t}
                | {:nvm, String.t}
		| {:npm, String.t}

  @type t :: %__MODULE__{}

  @doc """
  Creates new env
  """
  @spec new(options) :: t
  def new(options \\ []) do
    # Check version syntax
    {_, _, _, _} = Semver.parse(Keyword.get(options, :nvm, @default_nvm))
    {_, _, _, _} = Semver.parse(Keyword.get(options, :node, @default_node))
    {_, _, _, _} = Semver.parse(Keyword.get(options, :npm, @default_npm))
    
    %__MODULE__{
      dir: Keyword.get_lazy(options, :dir, fn -> :code.priv_dir(:nox) end),
      versions: [
	nvm: Keyword.get(options, :nvm, @default_nvm),
	node: Keyword.get(options, :node, @default_node),
	npm: Keyword.get(options, :npm, @default_npm)
      ]
    }
  end

  @doc """
  Creates default env
  """
  @spec default() :: t
  def default, do: new()
end
