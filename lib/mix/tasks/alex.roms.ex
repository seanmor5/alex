defmodule Mix.Tasks.Alex.Roms do
  @shortdoc "Installs Atari ROMs into ALEx's ROM directory"

  @moduledoc """
  Installs Atari 2600 ROMs so ALEx can find them by name.

  ALEx does not bundle game ROMs. This task materializes a set of `.bin` files
  into a ROM directory that `Alex.ROM` resolves against. It can pull ROMs from a
  few sources:

      # Download and extract an archive you point it at (.tar.gz/.tgz/.tar/.zip)
      mix alex.roms --url https://example.com/roms.tar.gz

      # Copy from an existing local directory of .bin files
      mix alex.roms --from /path/to/roms

      # Import from an installed ale-py package (pip install ale-py)
      mix alex.roms --ale-py

  With no source flag the task tries `--ale-py`, the most convenient legal source
  of a correctly-named ROM set.

  ## Destination

  ROMs are installed into the first of:

    1. the `--dir DIR` option,
    2. the `:alex, :rom_dir` application config,
    3. the `ALE_ROM_DIR` environment variable, or
    4. `./roms` (relative to the current directory).

  ## Options

    * `--url URL` — download and extract ROMs from an archive
    * `--from DIR` — copy `.bin` files from a local directory (recursively)
    * `--ale-py` — import ROMs from an installed `ale-py` package
    * `--dir DIR` — destination directory (see above)
    * `--force` — overwrite ROMs that already exist in the destination

  ## A note on ROMs

  Atari 2600 ROMs are copyrighted. ALEx does not distribute them; you are
  responsible for the legality of whatever source you point this task at.
  Installing `ale-py` (`pip install ale-py`) provides a ROM set blessed by the
  Farama Foundation and is the recommended source.
  """

  use Mix.Task

  @switches [url: :string, from: :string, ale_py: :boolean, dir: :string, force: :boolean]

  @impl true
  def run(args) do
    {opts, _argv, _invalid} = OptionParser.parse(args, strict: @switches)

    dest = destination(opts)
    File.mkdir_p!(dest)

    {source_dir, cleanup} = source(opts)

    try do
      install(source_dir, dest, opts[:force] == true)
    after
      cleanup.()
    end
  end

  # --- Destination -----------------------------------------------------------

  defp destination(opts) do
    opts[:dir] ||
      Application.get_env(:alex, :rom_dir) ||
      System.get_env("ALE_ROM_DIR") ||
      Path.join(File.cwd!(), "roms")
  end

  # --- Source resolution -----------------------------------------------------
  #
  # Returns {source_dir, cleanup_fun}. cleanup_fun removes any temporary files.

  defp source(opts) do
    cond do
      opts[:url] -> from_url(opts[:url])
      opts[:from] -> {expand_existing!(opts[:from]), &noop/0}
      true -> {from_ale_py!(), &noop/0}
    end
  end

  defp from_url(url) do
    tmp = Path.join(System.tmp_dir!(), "alex-roms-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    archive = Path.join(tmp, archive_name(url))

    Mix.shell().info("Downloading #{url}")
    download!(url, archive)

    Mix.shell().info("Extracting #{Path.basename(archive)}")
    extract!(archive, tmp)

    {tmp, fn -> File.rm_rf!(tmp) end}
  end

  defp from_ale_py! do
    case System.cmd(
           "python3",
           ["-c", "import ale_py, os; print(os.path.dirname(ale_py.__file__))"],
           stderr_to_stdout: true
         ) do
      {out, 0} ->
        dir = Path.join(String.trim(out), "roms")
        expand_existing!(dir)

      _ ->
        Mix.raise("""
        Could not import ale-py. Install it with:

            pip install ale-py

        or provide ROMs another way with --url or --from. See `mix help alex.roms`.
        """)
    end
  rescue
    e in ErlangError ->
      _ = e

      Mix.raise("""
      python3 is not available, so ROMs cannot be imported from ale-py.

      Provide ROMs another way with --url or --from. See `mix help alex.roms`.
      """)
  end

  defp expand_existing!(dir) do
    expanded = Path.expand(dir)

    unless File.dir?(expanded) do
      Mix.raise("Source directory does not exist: #{expanded}")
    end

    expanded
  end

  # --- Install ---------------------------------------------------------------

  defp install(source_dir, dest, force?) do
    roms = Path.wildcard(Path.join(source_dir, "**/*.bin"))

    if roms == [] do
      Mix.raise("No .bin ROM files found in #{source_dir}")
    end

    {copied, skipped} =
      Enum.reduce(roms, {0, 0}, fn rom, {copied, skipped} ->
        target = Path.join(dest, Path.basename(rom))

        if File.exists?(target) and not force? do
          {copied, skipped + 1}
        else
          File.cp!(rom, target)
          {copied + 1, skipped}
        end
      end)

    Mix.shell().info("Installed #{copied} ROM(s) into #{dest}")

    if skipped > 0 do
      Mix.shell().info("Skipped #{skipped} existing ROM(s) (use --force to overwrite)")
    end

    :ok
  end

  # --- Download + extract helpers --------------------------------------------

  defp download!(url, path) do
    case System.cmd("curl", ["-fSL", url, "-o", path], stderr_to_stdout: true) do
      {_, 0} ->
        :ok

      {out, _} ->
        Mix.raise("Download failed:\n#{out}")
    end
  rescue
    e in ErlangError ->
      _ = e
      Mix.raise("curl is required to download ROMs but was not found on PATH.")
  end

  defp extract!(archive, dest) do
    cond do
      String.ends_with?(archive, [".tar.gz", ".tgz"]) ->
        :ok = :erl_tar.extract(archive, [:compressed, {:cwd, dest}])

      String.ends_with?(archive, ".tar") ->
        :ok = :erl_tar.extract(archive, [{:cwd, dest}])

      String.ends_with?(archive, ".zip") ->
        {:ok, _} = :zip.extract(String.to_charlist(archive), [{:cwd, String.to_charlist(dest)}])
        :ok

      true ->
        Mix.raise(
          "Unsupported archive type: #{Path.basename(archive)} (expected .tar.gz/.tgz/.tar/.zip)"
        )
    end
  end

  defp archive_name(url) do
    name = url |> URI.parse() |> Map.get(:path, "") |> Path.basename()
    if name == "" or not String.contains?(name, "."), do: "roms.tar.gz", else: name
  end

  defp noop, do: :ok
end
