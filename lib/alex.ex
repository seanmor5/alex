defmodule Alex do
  alias Alex.Interface
  alias Alex.ROM
  @moduledoc """
  Arcade Learning Environment for Elixir.

  Alex is a port of the ALE for Elixir. There are two ways to interact with the ALE from Alex: through the `Alex.Interface` module which mimics the ALE C Lib and provides NIFs for interacting directly with the ALE C++ Interface, or through the `Alex` module which is just a more "Elixir-y" wrapper of `Alex.Interface`.
  """

  @doc """
  Initializes a new ALE Interface.

  Returns `%Interface{}`.

  # Parameters

    - `opts`: `Keyword` options.

  # Options

    - `:display_screen`: `true` or `false` to display screen.
    - `:random_seed`: `Integer` random seed.
  """
  def new(opts \\ []) do
    with {:ok, ale_ref} <- Interface.ale_new() do
      opts
      |> Enum.reduce(%Interface{ref: ale_ref},
          fn {key, val}, int ->
            set_option(int, key, val)
          end
        )
    else
      err -> raise err
    end
  end

  @doc """
  Loads the specified ROM.

  Returns `%Interface{}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def load_rom(interface, path_to_rom) do
    ale_ref = interface.ref
    with :ok <- ROM.check_rom_exists(path_to_rom),
         :ok <- ROM.check_rom_supported(path_to_rom) do
          Interface.load_rom(ale_ref, path_to_rom)
          %Interface{interface | rom: path_to_rom}
    else
      {:error, err} -> raise err
    end
  end

  @doc """
  Sets option for provided interface.

  Returns `%Interface{}`.

  # Parameters

    - `interface`: `%Interface{}` to set option for.
    - `key`: `Atom` or `String` key.
    - `val`: `String`, `Integer`, `Boolean`, or `Float` value.
  """
  def set_option(%Interface{} = interface, key, val) when is_atom(key), do:
    set_option(interface, Atom.to_string(key), val)

  def set_option(%Interface{} = interface, key, val) when is_binary(key) and is_binary(val) do
    ale_ref = interface.ref
    case Interface.set_string(ale_ref, key, val) do
      :ok -> Map.update!(interface, String.to_atom(key), fn _ -> val end)
      err -> {:error, err}
    end
  end

  def set_option(%Interface{} = interface, key, val) when is_binary(key) and is_integer(val) do
    ale_ref = interface.ref
    case Interface.set_int(ale_ref, key, val) do
      :ok -> Map.update!(interface, String.to_atom(key), fn _ -> val end)
      err -> {:error, err}
    end
  end

  def set_option(%Interface{} = interface, key, val) when is_binary(key) and is_boolean(val) do
    ale_ref = interface.ref
    case Interface.set_bool(ale_ref, key, val) do
      :ok -> Map.update!(interface, String.to_atom(key), fn _ -> val end)
      err -> {:error, err}
    end
  end

  def set_option(%Interface{} = interface, key, val) when is_binary(key) and is_float(val) do
    ale_ref = interface.ref
    case Interface.set_float(ale_ref, key, val) do
      :ok -> Map.update!(interface, String.to_atom(key), fn _ -> val end)
      err -> {:error, err}
    end
  end

  def set_option(_int, _key, _val), do:
    raise """
             Invalid arguments passed to set_option/3.
             interface must be %Interface{}.
             key must be binary or atom.
             value must be binary, integer, boolean, or float.
          """
end
