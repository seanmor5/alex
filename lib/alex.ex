defmodule Alex do
  alias Alex.Interface
  alias Alex.ROM
  alias Alex.State
  alias Alex.Screen

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
      |> Enum.reduce(
        %Interface{ref: ale_ref},
        fn {key, val}, int ->
          set_option(int, key, val)
        end
      )
    else
      err -> raise err
    end
  end

  @doc """
  Loads the specified ROM and populates fields in `%Interface{}`.

  Returns `%Interface{}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def load(%Interface{} = interface, path_to_rom) do
    ale_ref = interface.ref

    with :ok <- ROM.check_rom_exists(path_to_rom),
         :ok <- ROM.check_rom_supported(path_to_rom),
         :ok <- Interface.load_rom(ale_ref, path_to_rom),
         {:ok, modes} <- Interface.get_available_modes(ale_ref),
         {:ok, difficulties} <- Interface.get_available_difficulties(ale_ref),
         {:ok, legal_actions} <- Interface.get_legal_action_set(ale_ref),
         {:ok, min_actions} <- Interface.get_minimal_action_set(ale_ref),
         {:ok, lives} <- Interface.lives(ale_ref),
         {:ok, frame} <- Interface.get_frame_number(ale_ref),
         {:ok, episode_frame} <- Interface.get_episode_frame_number(ale_ref),
         {:ok, state} <- State.new(interface),
         {:ok, screen} <- Screen.new(interface) do
      %Interface{
        interface
        | rom: path_to_rom,
          modes: modes,
          difficulties: MapSet.new(difficulties),
          legal_actions: MapSet.new(legal_actions),
          minimal_actions: MapSet.new(min_actions),
          lives: lives,
          frame: frame,
          episode_frame: episode_frame,
          screen: screen,
          state: state
      }
    else
      {:error, err} -> raise err
    end
  end

  @doc """
  Performs a step with provided `action` and updates the interface.

  Returns `%Interface`.

  # Parameters

    - `interface`: `%Interface{}`.
    - `action`: `Integer` valid action.
  """
  def step(%Interface{} = interface, action) do
    ale_ref = interface.ref

    if not MapSet.member?(interface.legal_actions, action) do
    else
      with {:ok, reward} <- Interface.act(ale_ref, action),
           {:ok, lives} <- Interface.lives(ale_ref),
           {:ok, legal_actions} <- Interface.get_legal_action_set(ale_ref),
           {:ok, min_actions} <- Interface.get_minimal_action_set(ale_ref),
           {:ok, frame} <- Interface.get_frame_number(ale_ref),
           {:ok, episode_frame} <- Interface.get_episode_frame_number(ale_ref),
           {:ok, state} <- State.new(interface) do
        %Interface{
          interface
          | reward: interface.reward + reward,
            lives: lives,
            legal_actions: MapSet.new(legal_actions),
            minimal_actions: MapSet.new(min_actions),
            frame: frame,
            episode_frame: episode_frame,
            state: state
        }
      else
        err -> raise err
      end
    end
  end

  @doc """
  Checks if game is over.

  Returns `boolean`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def game_over?(%Interface{} = interface) do
    {:ok, game_over} = Interface.game_over(interface.ref)
    game_over
  end

  @doc """
  Resets the given interface.

  Returns `%Interface{}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def reset(%Interface{} = interface) do
    ale_ref = interface.ref
    Interface.reset_game(ale_ref)

    with {:ok, frame} <- Interface.get_frame_number(ale_ref),
         {:ok, episode_frame} <- Interface.get_episode_frame_number(ale_ref),
         {:ok, lives} <- Interface.lives(ale_ref),
         {:ok, legal_actions} <- Interface.get_legal_action_set(ale_ref),
         {:ok, min_actions} <- Interface.get_minimal_action_set(ale_ref),
         {:ok, state} <- State.new(interface),
         {:ok, screen} <- Screen.new(interface) do
      %Interface{
        interface
        | frame: frame,
          episode_frame: episode_frame,
          lives: lives,
          legal_actions: MapSet.new(legal_actions),
          minimal_actions: MapSet.new(min_actions),
          state: state,
          screen: screen
      }
    else
      err -> raise err
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
  def set_option(%Interface{} = interface, :difficulty, val) do
    ale_ref = interface.ref

    case interface.difficulties do
      nil ->
        raise "Could not find difficultues. Did you load a ROM?"

      _ ->
        if not MapSet.member?(interface.difficulties, val) do
          raise "#{val} not a valid difficulty. Must be one of: #{
                  MapSet.to_list(interface.difficulties)
                }"
        else
          :ok = Interface.set_difficulty(ale_ref, val)
          %Interface{interface | difficulty: val}
        end
    end
  end

  def set_option(%Interface{} = interface, "difficulty", val) do
    ale_ref = interface.ref

    case interface.difficulties do
      nil ->
        raise "Could not find difficultues. Did you load a ROM?"

      _ ->
        if not MapSet.member?(interface.difficulties, val) do
          raise "#{val} not a valid difficulty. Must be one of: #{
                  MapSet.to_list(interface.difficulties)
                }"
        else
          :ok = Interface.set_difficulty(ale_ref, val)
          %Interface{interface | difficulty: val}
        end
    end
  end

  def set_option(%Interface{} = interface, :mode, val) do
    ale_ref = interface.ref

    case interface.difficulties do
      nil ->
        raise "Could not find modes. Did you load a ROM?"

      _ ->
        if not MapSet.member?(interface.modes, val) do
          raise "#{val} not a valid mode. Must be one of: #{MapSet.to_list(interface.modes)}"
        else
          :ok = Interface.set_mode(ale_ref, val)
          %Interface{interface | mode: val}
        end
    end
  end

  def set_option(%Interface{} = interface, "mode", val) do
    ale_ref = interface.ref

    case interface.difficulties do
      nil ->
        raise "Could not find modes. Did you load a ROM?"

      _ ->
        if not MapSet.member?(interface.modes, val) do
          raise "#{val} not a valid mode. Must be one of: #{MapSet.to_list(interface.modes)}"
        else
          :ok = Interface.set_mode(ale_ref, val)
          %Interface{interface | mode: val}
        end
    end
  end

  def set_option(%Interface{} = interface, key, val) when is_atom(key),
    do: set_option(interface, Atom.to_string(key), val)

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

  def set_option(_int, _key, _val),
    do:
      raise("""
         Invalid arguments passed to set_option/3.
         interface must be %Interface{}.
         key must be binary or atom.
         value must be binary, integer, boolean, or float.
      """)
end
