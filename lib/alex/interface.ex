defmodule Alex.Interface do
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

  def load_nifs do
    :erlang.load_nif('./csrc/ale/alex/libale_c', 0)
  end

  def ale_new, do: raise("ale_new/0 not implemented.")
  def get_string(_ref, _key), do: raise("get_string/2 not implemented.")
  def get_int(_ref, _key), do: raise("get_int/2 not implemented.")
  def get_bool(_ref, _key), do: raise("get_bool/2 not implemented.")
  def get_float(_ref, _key), do: raise("get_float/2 not implemented.")
  def set_string(_ref, _key, _val), do: raise("set_string/3 not implemented.")
  def set_int(_ref, _key, _val), do: raise("set_int/3 not implemented.")
  def set_bool(_ref, _key, _val), do: raise("set_bool/3 not implemented.")
  def set_float(_ref, _key, _val), do: raise("set_float/3 not implemented.")
  def load_rom(_ref, _path), do: raise("load_rom/2 not implemented.")
  def act(_ref, _act), do: raise("act/2 not implemented.")
  def game_over(_ref), do: raise("game_over/1 not implemented.")
  def reset_game(_ref), do: raise("reset_game/1 not implemented.")
  def get_available_modes(_ref), do: raise("get_available_modes/1 not implemented.")
  def get_available_modes_size(_ref), do: raise("get_available_modes_size/1 not implemented.")
  def set_mode(_ref, _mode), do: raise("set_mode/2 not implemented.")
  def get_available_difficulties(_ref), do: raise("get_available_difficulties/1 not implemented.")

  def get_available_difficulties_size(_ref),
    do: raise("get_available_difficulties_size/1 not implemented.")

  def set_difficulty(_ref, _diff), do: raise("set_difficulty/2 not implemented.")
  def get_difficulty(_ref), do: raise "get_difficulty/1 not implemented."
  def get_legal_action_set(_ref), do: raise("get_legal_action_set/1 not implemented.")
  def get_legal_action_set_size(_ref), do: raise("get_legal_action_set_size/1 not implemented.")
  def get_minimal_action_set(_ref), do: raise("get_minimal_action_set/1 not implemented.")

  def get_minimal_action_set_size(_ref),
    do: raise("get_minimal_action_set_size/1 not implemented.")

  def get_frame_number(_ref), do: raise("get_frame_number/1 not implemented.")
  def lives(_ref), do: raise("lives/1 not implemented.")
  def get_episode_frame_number(_ref), do: "get_episode_frame_number/1 not implemented."
  def get_screen(_ref), do: raise "get_screen/1 not implemented."
  def get_ram(_ref), do: raise "get_ram/1 not implemented."
  def get_ram_size(_ref), do: raise("get_ram_size/1 not implemented.")
  def get_screen_width(_ref), do: raise("get_screen_width/1 not implemented.")
  def get_screen_height(_ref), do: raise("get_screen_height/1 not implemented.")
  def get_screen_rgb(_ref), do: raise "get_screen_rgb/1 not implemented."
  def get_screen_grayscale(_ref), do: raise "get_screen_grayscale/1 not implemented."
  def save_screen_png(_ref, _path), do: raise "save_screen_png/2 not implemented."
  def save_state(_ref), do: raise "save_state/1 not implemented."
  def load_state(_ref), do: raise "load_state/1 not implemented."
  def clone_state(_ref), do: raise "clone_state/1 not implemented."
  def restore_state(_ref, _state), do: raise "restore_state/1 not implemented."
  def clone_system_state(_ref), do: raise "clone_system_state/1 not implemented."
  def restore_system_state(_ref, _state), do: raise "restore_system_state/1 not implemented."
  def encode_state(_state), do: raise "encode_state/1 not implemented."
  def encode_state_len(_state), do: raise "encode_state_len/1 not implemented."
  def decode_state(_serial, _len), do: raise "decode_state/2 not implemented."
  def set_logger_mode(_mode), do: raise "set_logger_mode/1 not implemented."
end