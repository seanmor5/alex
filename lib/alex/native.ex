defmodule Alex.Native do
  @moduledoc false

  # Low-level NIF bindings to the Arcade Learning Environment.
  #
  # This module is a thin, direct mapping onto the ALE C++ interface and is
  # internal. Each function operates on opaque resource references
  # (`t:interface/0` and `t:state/0`) returned by the NIF. Prefer the high-level
  # `Alex` API unless you specifically need raw access.
  #
  # Functions raise on invalid input (for example loading a missing ROM, or
  # selecting an unavailable mode) rather than returning `{:error, _}` — the
  # surrounding Elixir layer is responsible for any validation and tagging.

  @typedoc "Opaque reference to an `ale::ALEInterface`."
  @opaque interface :: reference()

  @typedoc "Opaque reference to a cloned `ale::ALEState`."
  @opaque state :: reference()

  @on_load :__on_load__

  @doc false
  def __on_load__ do
    path = :filename.join(:code.priv_dir(:alex), ~c"alex")
    :erlang.load_nif(path, 0)
  end

  @nif_error "NIF not loaded — the alex native library failed to compile or load"

  ## Lifecycle

  @spec new_interface() :: interface()
  def new_interface, do: :erlang.nif_error(@nif_error)

  ## Settings

  @spec set_string(interface(), String.t(), String.t()) :: :ok
  def set_string(_ale, _key, _value), do: :erlang.nif_error(@nif_error)

  @spec set_int(interface(), String.t(), integer()) :: :ok
  def set_int(_ale, _key, _value), do: :erlang.nif_error(@nif_error)

  @spec set_bool(interface(), String.t(), boolean()) :: :ok
  def set_bool(_ale, _key, _value), do: :erlang.nif_error(@nif_error)

  @spec set_float(interface(), String.t(), float()) :: :ok
  def set_float(_ale, _key, _value), do: :erlang.nif_error(@nif_error)

  @spec get_string(interface(), String.t()) :: String.t()
  def get_string(_ale, _key), do: :erlang.nif_error(@nif_error)

  @spec get_int(interface(), String.t()) :: integer()
  def get_int(_ale, _key), do: :erlang.nif_error(@nif_error)

  @spec get_bool(interface(), String.t()) :: boolean()
  def get_bool(_ale, _key), do: :erlang.nif_error(@nif_error)

  @spec get_float(interface(), String.t()) :: float()
  def get_float(_ale, _key), do: :erlang.nif_error(@nif_error)

  ## ROM / game loop

  @spec load_rom(interface(), String.t()) :: :ok
  def load_rom(_ale, _path), do: :erlang.nif_error(@nif_error)

  @spec act(interface(), integer()) :: integer()
  def act(_ale, _action), do: :erlang.nif_error(@nif_error)

  @spec game_over(interface()) :: boolean()
  def game_over(_ale), do: :erlang.nif_error(@nif_error)

  @spec game_truncated(interface()) :: boolean()
  def game_truncated(_ale), do: :erlang.nif_error(@nif_error)

  @spec reset_game(interface()) :: :ok
  def reset_game(_ale), do: :erlang.nif_error(@nif_error)

  @spec lives(interface()) :: integer()
  def lives(_ale), do: :erlang.nif_error(@nif_error)

  @spec get_frame_number(interface()) :: integer()
  def get_frame_number(_ale), do: :erlang.nif_error(@nif_error)

  @spec get_episode_frame_number(interface()) :: integer()
  def get_episode_frame_number(_ale), do: :erlang.nif_error(@nif_error)

  ## Action sets / modes / difficulties

  @spec legal_action_set(interface()) :: [integer()]
  def legal_action_set(_ale), do: :erlang.nif_error(@nif_error)

  @spec minimal_action_set(interface()) :: [integer()]
  def minimal_action_set(_ale), do: :erlang.nif_error(@nif_error)

  @spec available_modes(interface()) :: [integer()]
  def available_modes(_ale), do: :erlang.nif_error(@nif_error)

  @spec set_mode(interface(), integer()) :: :ok
  def set_mode(_ale, _mode), do: :erlang.nif_error(@nif_error)

  @spec get_mode(interface()) :: integer()
  def get_mode(_ale), do: :erlang.nif_error(@nif_error)

  @spec available_difficulties(interface()) :: [integer()]
  def available_difficulties(_ale), do: :erlang.nif_error(@nif_error)

  @spec set_difficulty(interface(), integer()) :: :ok
  def set_difficulty(_ale, _difficulty), do: :erlang.nif_error(@nif_error)

  @spec get_difficulty(interface()) :: integer()
  def get_difficulty(_ale), do: :erlang.nif_error(@nif_error)

  ## Observations

  @spec screen_dims(interface()) :: {height :: integer(), width :: integer()}
  def screen_dims(_ale), do: :erlang.nif_error(@nif_error)

  @spec screen_rgb(interface()) :: binary()
  def screen_rgb(_ale), do: :erlang.nif_error(@nif_error)

  @spec screen_grayscale(interface()) :: binary()
  def screen_grayscale(_ale), do: :erlang.nif_error(@nif_error)

  @spec get_ram(interface()) :: binary()
  def get_ram(_ale), do: :erlang.nif_error(@nif_error)

  @spec save_screen_png(interface(), String.t()) :: :ok
  def save_screen_png(_ale, _path), do: :erlang.nif_error(@nif_error)

  ## State snapshots

  @spec clone_state(interface(), boolean()) :: state()
  def clone_state(_ale, _include_rng), do: :erlang.nif_error(@nif_error)

  @spec restore_state(interface(), state()) :: :ok
  def restore_state(_ale, _state), do: :erlang.nif_error(@nif_error)

  @spec serialize_state(state()) :: binary()
  def serialize_state(_state), do: :erlang.nif_error(@nif_error)

  @spec deserialize_state(binary()) :: state()
  def deserialize_state(_serialized), do: :erlang.nif_error(@nif_error)
end
