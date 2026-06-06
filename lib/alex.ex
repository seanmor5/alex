defmodule Alex do
  @moduledoc """
  (A)rcade (L)earning (E)nvironment for Eli(x)ir.

  ALEx is an Elixir interface to the [Arcade Learning
  Environment](https://github.com/Farama-Foundation/Arcade-Learning-Environment),
  the standard platform for Atari 2600 reinforcement-learning research.

  The typical loop looks like this:

      env = Alex.new("breakout")

      env =
        Enum.reduce_while(Stream.cycle([:run]), env, fn _, env ->
          {env, info} = Alex.step(env, Enum.random(Alex.minimal_actions(env)))
          if info.game_over?, do: {:halt, env}, else: {:cont, env}
        end)

      IO.puts("Episode reward: \#{Alex.episode_reward(env)}")

  An `%Alex.Env{}` wraps a single, mutable emulator. `step/2` and `reset/1`
  advance it in place; use `Alex.Snapshot` to branch or rewind.

  ROMs are resolved by name against a ROM directory — see `Alex.ROM` for how the
  directory is configured. You can also pass an explicit path to a `.bin` file.
  """

  alias Alex.{Action, Env, Native, ROM}

  # Option name -> {setter, ALE setting key}. Applied before the ROM is loaded,
  # which is required for ALE settings to take effect.
  @settings %{
    display_screen: {:bool, "display_screen"},
    sound: {:bool, "sound"},
    random_seed: {:int, "random_seed"},
    repeat_action_probability: {:float, "repeat_action_probability"},
    frame_skip: {:int, "frame_skip"},
    max_num_frames_per_episode: {:int, "max_num_frames_per_episode"}
  }

  @doc """
  Loads a game and returns a ready-to-play `%Alex.Env{}`.

  `rom` is either a game name (resolved via `Alex.ROM`) or a path to a `.bin`
  file.

  ## Options

  Emulator settings (applied before the ROM loads):

    * `:display_screen` — open an SDL window (requires an SDL-enabled build)
    * `:sound` — enable audio (requires an SDL-enabled build)
    * `:random_seed` — integer seed for reproducibility
    * `:repeat_action_probability` — sticky-action probability (float, ALE
      default `0.25`)
    * `:frame_skip` — number of frames each action is held for
    * `:max_num_frames_per_episode` — episode truncation limit

  Game configuration (applied after the ROM loads):

    * `:mode` — initial game mode (must be in `env.modes`)
    * `:difficulty` — initial difficulty (must be in `env.difficulties`)

  ROM resolution:

    * `:rom_dir` — directory to resolve `rom` against (see `Alex.ROM`)
  """
  @spec new(String.t(), keyword()) :: Env.t()
  def new(rom, opts \\ []) when is_binary(rom) do
    ref = Native.new_interface()
    apply_settings(ref, opts)

    path = ROM.resolve!(rom, opts)
    :ok = Native.load_rom(ref, path)

    Env.from_ref(ref, path)
    |> maybe_apply(opts[:mode], &set_mode/2)
    |> maybe_apply(opts[:difficulty], &set_difficulty/2)
  end

  @doc """
  Applies `action` for one step and returns `{env, info}`.

  `action` is an `Alex.Action` name (e.g. `:fire`) or its integer value. `info`
  is a map:

    * `:reward` — reward from this step
    * `:episode_reward` — cumulative reward since the last `reset/1`
    * `:game_over?` — whether the episode has ended
    * `:truncated?` — whether the episode was truncated (e.g. frame limit)
    * `:lives` — remaining lives
    * `:frame` — total frame number since the ROM loaded
    * `:episode_frame` — frame number within the current episode
  """
  @spec step(Env.t(), Action.t() | integer()) ::
          {Env.t(), %{required(atom()) => term()}}
  def step(%Env{ref: ref} = env, action) do
    unless Action.valid?(action) do
      raise ArgumentError,
            "invalid action #{inspect(action)}, expected one of #{inspect(Action.all())} " <>
              "or an integer 0..17"
    end

    reward = Native.act(ref, Action.to_integer(action))
    env = %{env | episode_reward: env.episode_reward + reward}

    info = %{
      reward: reward,
      episode_reward: env.episode_reward,
      game_over?: Native.game_over(ref),
      truncated?: Native.game_truncated(ref),
      lives: Native.lives(ref),
      frame: Native.get_frame_number(ref),
      episode_frame: Native.get_episode_frame_number(ref)
    }

    {env, info}
  end

  @doc """
  Resets the emulator to the start of a new episode and zeroes the episode
  reward.
  """
  @spec reset(Env.t()) :: Env.t()
  def reset(%Env{ref: ref} = env) do
    :ok = Native.reset_game(ref)
    %{env | episode_reward: 0}
  end

  @doc "Whether the current episode is over."
  @spec game_over?(Env.t()) :: boolean()
  def game_over?(%Env{ref: ref}), do: Native.game_over(ref)

  @doc "Whether the current episode was truncated (e.g. hit the frame limit)."
  @spec truncated?(Env.t()) :: boolean()
  def truncated?(%Env{ref: ref}), do: Native.game_truncated(ref)

  @doc "Remaining lives."
  @spec lives(Env.t()) :: non_neg_integer()
  def lives(%Env{ref: ref}), do: Native.lives(ref)

  @doc "Total frame number since the ROM was loaded."
  @spec frame(Env.t()) :: non_neg_integer()
  def frame(%Env{ref: ref}), do: Native.get_frame_number(ref)

  @doc "Frame number within the current episode."
  @spec episode_frame(Env.t()) :: non_neg_integer()
  def episode_frame(%Env{ref: ref}), do: Native.get_episode_frame_number(ref)

  @doc "Cumulative reward since the last `reset/1`."
  @spec episode_reward(Env.t()) :: number()
  def episode_reward(%Env{episode_reward: reward}), do: reward

  @doc "The full set of console actions, as `Alex.Action` atoms."
  @spec legal_actions(Env.t()) :: [Action.t()]
  def legal_actions(%Env{legal_actions: actions}), do: actions

  @doc "The minimal set of actions that affect this game, as `Alex.Action` atoms."
  @spec minimal_actions(Env.t()) :: [Action.t()]
  def minimal_actions(%Env{minimal_actions: actions}), do: actions

  @doc "The game mode currently in effect."
  @spec mode(Env.t()) :: non_neg_integer()
  def mode(%Env{ref: ref}), do: Native.get_mode(ref)

  @doc "The difficulty currently in effect."
  @spec difficulty(Env.t()) :: non_neg_integer()
  def difficulty(%Env{ref: ref}), do: Native.get_difficulty(ref)

  @doc """
  Sets the game mode and resets the episode so it takes effect.

  `mode` must be a member of `env.modes`.
  """
  @spec set_mode(Env.t(), non_neg_integer()) :: Env.t()
  def set_mode(%Env{ref: ref, modes: modes} = env, mode) do
    unless mode in modes do
      raise ArgumentError,
            "#{inspect(mode)} is not an available mode, expected one of #{inspect(modes)}"
    end

    :ok = Native.set_mode(ref, mode)
    reset(env)
  end

  @doc """
  Sets the difficulty and resets the episode so it takes effect.

  `difficulty` must be a member of `env.difficulties`.
  """
  @spec set_difficulty(Env.t(), non_neg_integer()) :: Env.t()
  def set_difficulty(%Env{ref: ref, difficulties: difficulties} = env, difficulty) do
    unless difficulty in difficulties do
      raise ArgumentError,
            "#{inspect(difficulty)} is not an available difficulty, expected one of #{inspect(difficulties)}"
    end

    :ok = Native.set_difficulty(ref, difficulty)
    reset(env)
  end

  defp apply_settings(ref, opts) do
    for {key, {type, ale_key}} <- @settings, Keyword.has_key?(opts, key) do
      value = Keyword.fetch!(opts, key)

      case type do
        :bool -> Native.set_bool(ref, ale_key, value)
        :int -> Native.set_int(ref, ale_key, value)
        :float -> Native.set_float(ref, ale_key, value)
      end
    end

    :ok
  end

  defp maybe_apply(env, nil, _fun), do: env
  defp maybe_apply(env, value, fun), do: fun.(env, value)
end
