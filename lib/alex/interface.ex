defmodule Alex.Interface do
  @moduledoc """
  NIFs for interfacing with Arcade Learning Environment.

  This module exposes the low-level interface for the Arcade Learning Environment. Use at your own risk.
  """
  @on_load :load_nifs

  @enforce_keys [:ref]
  defstruct [
    :ref,
    rom: nil,
    display_screen: false,
    random_seed: :rand.uniform(999_999),
    modes: nil,
    mode: 0,
    difficulties: nil,
    difficulty: 0,
    legal_actions: nil,
    minimal_actions: nil,
    lives: 0,
    frame: 0,
    episode_frame: 0,
    screen: nil,
    state: nil,
    ram: nil,
    reward: 0
  ]

  @doc false
  def load_nifs do
    :erlang.load_nif('./csrc/ale/alex/libale_c', 0)
  end

  @doc """
  NIF. Creates a new ALE interface.

  Returns `{:ok, #Reference<>}`.
  """
  def ale_new, do: raise("ale_new/0 not implemented.")

  @doc """
  NIF. Get string setting by `key`.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
  """
  def get_string(_ref, _key), do: raise("get_string/2 not implemented.")

  @doc """
  NIF. Get integer setting by `key`.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
  """
  def get_int(_ref, _key), do: raise("get_int/2 not implemented.")

  @doc """
  NIF. Get boolean setting by `key`.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
  """
  def get_bool(_ref, _key), do: raise("get_bool/2 not implemented.")

  @doc """
  NIF. Get float setting by `key`.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
  """
  def get_float(_ref, _key), do: raise("get_float/2 not implemented.")

  @doc """
  NIF. Sets `key` to string `val`.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
    - `val`: `String` value.
  """
  def set_string(_ref, _key, _val), do: raise("set_string/3 not implemented.")

  @doc """
  NIF. Sets `key` to integer `val`.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
    - `val`: `Integer` value.
  """
  def set_int(_ref, _key, _val), do: raise("set_int/3 not implemented.")

  @doc """
  NIF. Sets `key` to boolean `val`.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
    - `val`: `Boolean` value.
  """
  def set_bool(_ref, _key, _val), do: raise("set_bool/3 not implemented.")

  @doc """
  NIF. Sets `key` to float `val`.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `key`: `String` key.
    - `val`: `Float` value.
  """
  def set_float(_ref, _key, _val), do: raise("set_float/3 not implemented.")

  @doc """
  NIF. Loads the specified ROM file.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `path`: Path to ROM file.
  """
  def load_rom(_ref, _path), do: raise("load_rom/2 not implemented.")

  @doc """
  NIF. Performs specified action.

  Returns `{:ok, reward}`.

  # Parameters

    - `ref`: Reference to ALE.
    - `action`: `Integer` action.
  """
  def act(_ref, _act), do: raise("act/2 not implemented.")

  @doc """
  NIF. Determines if the game is over.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def game_over(_ref), do: raise("game_over/1 not implemented.")

  @doc """
  NIF. Resets the game.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def reset_game(_ref), do: raise("reset_game/1 not implemented.")

  @doc """
  NIF. Gets available game modes.

  Returns `{:ok, [...]}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_available_modes(_ref), do: raise("get_available_modes/1 not implemented.")

  @doc """
  NIF. Gets number of available game modes.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_available_modes_size(_ref), do: raise("get_available_modes_size/1 not implemented.")

  @doc """
  NIF. Sets the game mode.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `mode`: `Integer` game mode.
  """
  def set_mode(_ref, _mode), do: raise("set_mode/2 not implemented.")

  @doc """
  NIF. Gets available game difficulties.

  Returns `{:ok, [...]}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_available_difficulties(_ref), do: raise("get_available_difficulties/1 not implemented.")

  @doc """
  NIF. Gets number of available difficulties.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_available_difficulties_size(_ref),
    do: raise("get_available_difficulties_size/1 not implemented.")

  @doc """
  NIF. Sets the difficulty of game.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
    - `difficulty`: `Integer` difficulty.
  """
  def set_difficulty(_ref, _diff), do: raise("set_difficulty/2 not implemented.")

  @doc """
  NIF. Gets current difficulty.

  Returns `{:ok, difficulty}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_difficulty(_ref), do: raise("get_difficulty/1 not implemented.")

  @doc """
  NIF. Gets the current legal action set.

  Returns `{:ok, [...]}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_legal_action_set(_ref), do: raise("get_legal_action_set/1 not implemented.")

  @doc """
  NIF. Gets the number of current legal actions.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_legal_action_set_size(_ref), do: raise("get_legal_action_set_size/1 not implemented.")

  @doc """
  NIF. Gets the minimal action set.

  Returns `{:ok, [...]}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_minimal_action_set(_ref), do: raise("get_minimal_action_set/1 not implemented.")

  @doc """
  NIF. Gets the number of current minimal actions.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_minimal_action_set_size(_ref),
    do: raise("get_minimal_action_set_size/1 not implemented.")

  @doc """
  NIF. Gets the current frame number.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_frame_number(_ref), do: raise("get_frame_number/1 not implemented.")

  @doc """
  NIF. Gets the current number of lives.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def lives(_ref), do: raise("lives/1 not implemented.")

  @doc """
  NIF. Gets the current episode frame number.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_episode_frame_number(_ref), do: "get_episode_frame_number/1 not implemented."

  @doc """
  NIF. Gets the current screen.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_screen(_ref), do: raise("get_screen/1 not implemented.")

  @doc """
  NIF. Gets the current RAM.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_ram(_ref), do: raise("get_ram/1 not implemented.")

  @doc """
  NIF. Gets the current RAM size.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_ram_size(_ref), do: raise("get_ram_size/1 not implemented.")

  @doc """
  NIF. Gets the current screen width.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_screen_width(_ref), do: raise("get_screen_width/1 not implemented.")

  @doc """
  NIF. Gets the current screen height.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_screen_height(_ref), do: raise("get_screen_height/1 not implemented.")

  @doc """
  NIF. Gets the current screen in RGB format.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_screen_rgb(_ref), do: raise("get_screen_rgb/1 not implemented.")

  @doc """
  NIF. Gets the current screen in grayscale format.

  Returns `{:ok, result}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def get_screen_grayscale(_ref), do: raise("get_screen_grayscale/1 not implemented.")

  @doc """
  NIF. Saves the current screen as png to path.

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE
    - `path`: Path to save.
  """
  def save_screen_png(_ref, _path), do: raise("save_screen_png/2 not implemented.")

  @doc """
  NIF. Saves the current state.

  Not really sure what this does...

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def save_state(_ref), do: raise("save_state/1 not implemented.")

  @doc """
  NIF. Loads the current state.

  Not really sure what this does...

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def load_state(_ref), do: raise("load_state/1 not implemented.")

  @doc """
  NIF. Returns the current state reference.

  Returns `{:ok, state}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def clone_state(_ref), do: raise("clone_state/1 not implemented.")

  @doc """
  NIF. Restores the interface to specified state.

  Returns `{:ok, state}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def restore_state(_ref, _state), do: raise("restore_state/1 not implemented.")

  @doc """
  NIF. Returns the current system state reference.

  Not really sure what this does...

  Returns `{:ok, state}`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def clone_system_state(_ref), do: raise("clone_system_state/1 not implemented.")

  @doc """
  NIF. Restores the interface to specified system state.

  Not really sure what this does...

  Returns `:ok`.

  # Parameters

    - `ref`: Reference to ALE.
  """
  def restore_system_state(_ref, _state), do: raise("restore_system_state/1 not implemented.")

  @doc """
  NIF. Serializes the state reference.

  Returns `{:ok, encoded}`.

  # Parameters

    - `state`: Reference to state.
  """
  def encode_state(_state), do: raise("encode_state/1 not implemented.")

  @doc """
  NIF. Returns length of encoded state.

  Returns `{:ok, length}`.

  # Parameters

    - `state`: Reference to state.
  """
  def encode_state_len(_state), do: raise("encode_state_len/1 not implemented.")

  @doc """
  NIF. Decodes serialized state.

  Returns `{:ok, state}`.

  # Parameters

    - `state`: serialized state.
    - `len`: length of serialized state.
  """
  def decode_state(_serial, _len), do: raise("decode_state/2 not implemented.")

  @doc """
  NIF. Sets mode of ALE logger.

  Returns `:ok`.

  # Parameters

    - `mode`: `0`, `1`, or `2`.
  """
  def set_logger_mode(_mode), do: raise("set_logger_mode/1 not implemented.")
end
