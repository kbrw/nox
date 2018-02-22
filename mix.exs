defmodule Nox.MixProject do
  use Mix.Project

  def project do
    [
      app: :nox,
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
	compile: ["nox.install", "compile"],
	clean: ["nox.clean", "clean"]
      ],
      docs: docs()
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
      links: %{ "GitHub" => "https://github.com/kbrw/nox"},
      source_url: "https://github.com/kbrw/nox"
    ]
  end

  defp description, do: """
  Embed a safe and reproductible node environment into your Elixir application
  """

  defp docs, do: [
    main: "readme",
    logo: "_doc/nox.png",
    extras: [
      "README.md"
    ],
    source_url: "https://github.com/kbrw/nox",
    groups_for_modules: [
      "Common": [
    	Nox,
    	Nox.Cli,
    	Nox.Cli.Stream,
    	Nox.Semver,
    	Nox.Nvm
      ],
      "Wrappers": [
    	Nox.Node,
    	Nox.Npm,
    	Nox.Grunt
      ],
      "Parsers": [
    	Nox.Parser,
    	Nox.Parsers.Logger,
    	Nox.Parsers.Npm,
    	Nox.Parsers.Grunt
      ]
    ]
  ]
end
