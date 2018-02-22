[![Build Status](https://secure.travis-ci.org/kbrw/nox.svg?branch=master "Build Status")](http://travis-ci.org/kbrw/nox)

# Nox

Embeds node, npm and provides wrappers for running it.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nox, "~> 0.1.0"}
  ]
end
```

The docs is available at [https://hexdocs.pm/nox](https://hexdocs.pm/nox)

## Usage

Get full path to executable:

```elixir
Nox.which("node")
```

Get OS env for executing command in the node environment, for instance
to give to `env` option of `System.cmd/3`:

```elixir
env = Nox.env()
System.cmd("aglio", ["-i", "doc.in", "-o", "doc.out"], env: env)
```

Nox provides also wrappers for some well-know commands: see `Nox.Npm`,
`Nox.Grunt`.

## Command line parsers

Nox includes tools for parsing command line output, as for `into`
option of `System.cmd/3`.

If you simply want to redirect command output to `Logger`:

```elixir
System.cmd("echo", ["\"my tailor is rich\""], into: Nox.Cli.stream())
```

If you want to use a custom parser:

```elixir
System.cmd("npm", ["install"], into: Nox.Cli.stream({Nox.Parsers.Npm, []}))
```

## License

Nox source code is released under Apache 2 License.

Check the [LICENSE](LICENSE) file for more information.
