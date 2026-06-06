defmodule Alex.ROM do
  @moduledoc """
  Locating Atari ROM files.

  ALE no longer ships game ROMs with its C++ library, and ALEx does not bundle
  them either (with the exception of `tetris.bin`, kept only as a test fixture).
  Instead, ROMs are resolved by name against a *ROM directory*. The directory is
  determined by the first of these that is set:

    1. an explicit `:rom_dir` option passed to the resolving function,
    2. the `:alex, :rom_dir` application environment,
    3. the `ALE_ROM_DIR` operating-system environment variable,
    4. the `roms/` directory of an installed `ale-py` (auto-detected), and
    5. the `priv/roms` directory bundled with ALEx (contains only `tetris`).

  A ROM "name" is the snake-cased game name without extension, e.g. `"breakout"`
  or `"space_invaders"`.
  """

  @doc """
  Resolves a ROM name (or path) to an absolute file path.

  If `name_or_path` points at an existing file it is returned as-is (expanded).
  Otherwise it is treated as a game name and looked up in the ROM directory.

  Returns `{:ok, path}` or `{:error, reason}`.

  ## Options

    * `:rom_dir` — override the ROM directory for this lookup.
  """
  @spec resolve(String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def resolve(name_or_path, opts \\ []) when is_binary(name_or_path) do
    expanded = Path.expand(name_or_path)

    if File.regular?(expanded) do
      {:ok, expanded}
    else
      dir = rom_dir(opts)
      path = Path.join(dir, normalize(name_or_path))

      if File.regular?(path) do
        {:ok, path}
      else
        {:error,
         "could not find ROM #{inspect(name_or_path)}. Looked for #{inspect(path)}. " <>
           "Set the ROM directory via the :rom_dir option, the :alex, :rom_dir application " <>
           "config, or the ALE_ROM_DIR environment variable."}
      end
    end
  end

  @doc """
  Like `resolve/2` but raises on failure.
  """
  @spec resolve!(String.t(), keyword()) :: String.t()
  def resolve!(name_or_path, opts \\ []) do
    case resolve(name_or_path, opts) do
      {:ok, path} -> path
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Lists the ROM names available in the configured ROM directory.
  """
  @spec list(keyword()) :: [String.t()]
  def list(opts \\ []) do
    dir = rom_dir(opts)

    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".bin"))
        |> Enum.map(&Path.basename(&1, ".bin"))
        |> Enum.sort()

      {:error, _} ->
        []
    end
  end

  @doc """
  Returns the ROM directory that would be used given `opts`.
  """
  @spec rom_dir(keyword()) :: String.t()
  def rom_dir(opts \\ []) do
    opts[:rom_dir] ||
      Application.get_env(:alex, :rom_dir) ||
      System.get_env("ALE_ROM_DIR") ||
      ale_py_roms() ||
      bundled_roms()
  end

  defp normalize(name) do
    if String.ends_with?(name, ".bin"), do: name, else: name <> ".bin"
  end

  defp bundled_roms do
    Path.join(:code.priv_dir(:alex), "roms")
  end

  # Best-effort detection of an installed ale-py package's bundled ROMs.
  defp ale_py_roms do
    with {out, 0} <-
           System.cmd(
             "python3",
             ["-c", "import ale_py, os; print(os.path.dirname(ale_py.__file__))"],
             stderr_to_stdout: true
           ),
         dir = Path.join(String.trim(out), "roms"),
         true <- File.dir?(dir) do
      dir
    else
      _ -> nil
    end
  rescue
    _ -> nil
  end
end
