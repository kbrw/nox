defmodule Nox.Env do
  @moduledoc """
  Environment of node installation
  
  If new/1 is called with `shared: true`, directory is built from a hash
  of (parsed) versions and thus, will be shared between all envs using 
  these versions.
  """
  alias Nox.Semver

  defstruct dir: nil, versions: []

  @default_nvm "v1.1.2"
  @default_node "8.9.4"
  @default_npm "5.6"

  @type options :: [option]
  @type option :: {:dir, Path.t}
                | {:shared, boolean}
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

    versions = [
      nvm: Keyword.get(options, :nvm, @default_nvm),
      node: Keyword.get(options, :node, @default_node),
      npm: Keyword.get(options, :npm, @default_npm)
    ]
    dir = if Keyword.get(options, :shared, false) do
      find_shared(versions)
    else
      Keyword.get_lazy(options, :dir, fn -> :code.priv_dir(:nox) end)
    end	    
    
    %__MODULE__{ dir: dir, versions: versions }
  end

  @doc """
  Creates default env
  """
  @spec default() :: t
  def default, do: new(shared: false)

  ###
  ### Priv
  ###
  def find_shared(versions) do
    hash = Enum.sort(versions) |>
      Enum.reduce(:crypto.hash_init(:sha256), fn
	{util, vsn}, ctx ->
	  vhash = :erlang.phash2({util, Semver.parse(vsn)})
	:crypto.hash_update(ctx, "#{vhash}")
      end) |>
      :crypto.hash_final() |>
      Base.url_encode64()
    Path.join Application.get_env(:nox, :shared_dir), "nox-#{hash}"
  end
end
