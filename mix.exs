defmodule Nodex.MixProject do
  use Mix.Project

  def project do
    [
      app: :nodex,
      version: "0.1.0",
      elixir: ">= 1.3.0",
      start_permanent: Mix.env() == :prod,
      versions: [
	nvm: "v1.1.2",
	node: "8.9.4",
	npm: "5.6"
      ],
      deps: deps(),
      aliases: [
	compile: ["nodex.install", "compile"],
	clean: ["nodex.clean", "clean"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
