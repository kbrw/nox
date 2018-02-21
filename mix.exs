defmodule Nodex.MixProject do
  use Mix.Project

  def project do
    [
      app: :nodex,
      version: "0.1.0",
      elixir: ">= 1.3.0",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
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
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Jean Parpaillon"],
      licenses: ["Apache License 2.0"],
      links: %{ "GitHub" => "https://github.com/kbrw/nodex"},
      source_url: "https://github.com/kbrw/nodex"
    ]
  end

  defp description, do: """
  Embed a safe and reproductible node environment into your Elixir application
  """
end
