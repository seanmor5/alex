defmodule Alex.Snapshot do
  @moduledoc """
  Saving and restoring ALE state.

  A snapshot captures the emulator state so you can rewind or branch — essential
  for planning and search. Two flavours:

    * `save/2` with `include_rng: false` (the default) omits the pseudo-random
      number generator, which is what you want for planning: restoring is
      deterministic with respect to the captured state.
    * `save/2` with `include_rng: true` captures the RNG too, suitable for
      faithfully serializing and resuming an episode.

  Snapshots can be `serialize/1`'d to a binary for persistence and rebuilt with
  `deserialize/1`. Because ALEx and the `Alex.Kino` browser emulator are pinned
  to the same ALE version, these bytes are interchangeable with the WebAssembly
  build's `saveState()` output.
  """

  alias Alex.{Env, Native}

  @enforce_keys [:ref]
  defstruct [:ref]

  @type t :: %__MODULE__{ref: reference()}

  @doc """
  Captures the current state of `env`.

  ## Options

    * `:include_rng` — also capture the RNG (default `false`).
  """
  @spec save(Env.t(), keyword()) :: t()
  def save(%Env{ref: ref}, opts \\ []) do
    include_rng = Keyword.get(opts, :include_rng, false)
    %__MODULE__{ref: Native.clone_state(ref, include_rng)}
  end

  @doc """
  Restores `env` to a previously captured `snapshot`.

  Returns the env with its episode reward reset to `0`, since the cumulative
  reward bookkeeping cannot be recovered from the emulator state alone.
  """
  @spec restore(Env.t(), t()) :: Env.t()
  def restore(%Env{ref: ref} = env, %__MODULE__{ref: state}) do
    :ok = Native.restore_state(ref, state)
    %{env | episode_reward: 0}
  end

  @doc """
  Serializes a snapshot to a binary.
  """
  @spec serialize(t()) :: binary()
  def serialize(%__MODULE__{ref: state}) do
    Native.serialize_state(state)
  end

  @doc """
  Rebuilds a snapshot from a binary produced by `serialize/1` (or by the
  WebAssembly build's `saveState()`).
  """
  @spec deserialize(binary()) :: t()
  def deserialize(serialized) when is_binary(serialized) do
    %__MODULE__{ref: Native.deserialize_state(serialized)}
  end
end
