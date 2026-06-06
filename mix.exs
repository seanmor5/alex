defmodule Alex.MixProject do
  use Mix.Project

  @version "0.4.0"
  @url "https://github.com/seanmor5/alex"
  @maintainers ["Sean Moriarity"]

  # Pinned upstream Arcade Learning Environment release. The native library is
  # fetched and built from this tag by the Makefile, and the WebAssembly assets
  # used by `Alex.Kino` are pulled from the matching npm release. Keeping both
  # sides on the same version is what makes serialized ALE states interchangeable
  # between the native NIF and the in-browser emulator.
  @ale_version "v0.12.0"

  def project do
    [
      app: :alex,
      name: "ALEx",
      version: @version,
      elixir: "~> 1.15",
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      make_env: &make_env/0,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      description: description(),
      source_url: @url,
      homepage_url: @url,
      maintainers: @maintainers,
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:fine, "~> 0.1", runtime: false},
      {:elixir_make, "~> 0.8", runtime: false},
      {:kino, "~> 0.12", optional: true},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  # Environment passed through to the Makefile. Fine and the ERTS headers are
  # required to compile the NIF; ALE_VERSION selects the upstream release to
  # fetch and build.
  defp make_env do
    %{
      "FINE_INCLUDE_DIR" => Fine.include_dir(),
      "ERTS_INCLUDE_DIR" =>
        Path.join([:code.root_dir(), "erts-#{:erlang.system_info(:version)}", "include"]),
      "ALE_VERSION" => @ale_version,
      "MIX_BUILD_DIR" => Mix.Project.build_path(),
      "PATH" => build_path_env()
    }
  end

  # The build shells out to `cmake` (and `git`/`make`). Some hosts — notably
  # Livebook Desktop — run the BEAM with a minimal PATH that omits the Homebrew
  # bin directories where those tools live, so the build can't find them. Append
  # the common locations so `mix compile` works out of the box there too.
  defp build_path_env do
    extra = ["/opt/homebrew/bin", "/usr/local/bin", "/home/linuxbrew/.linuxbrew/bin"]
    current = System.get_env("PATH") || ""

    (String.split(current, ":", trim: true) ++ extra)
    |> Enum.uniq()
    |> Enum.join(":")
  end

  defp description do
    "ALEx lets you run the Arcade Learning Environment from Elixir."
  end

  defp package do
    [
      name: "alex",
      maintainers: @maintainers,
      licenses: ["GPL-2.0-only"],
      links: %{"GitHub" => @url},
      files: ~w(lib c_src Makefile mix.exs README.md CHANGELOG.md
                guides priv/roms/tetris.bin .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "getting-started",
      source_ref: "v#{@version}",
      extra_section: "guides",
      extras: [
        "guides/getting-started.md",
        "guides/installation.md",
        "guides/configuration.md",
        "guides/supported-roms.md"
      ]
    ]
  end
end
