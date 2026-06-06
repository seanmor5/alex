defmodule Alex.Env do
  @moduledoc """
  A loaded Arcade Learning Environment.

  An `%Alex.Env{}` wraps an opaque, **mutable** ALE emulator. Functions like
  `Alex.step/2` and `Alex.reset/1` advance that single underlying
  emulator in place. To branch or rewind, take an explicit `Alex.Snapshot`.

  ## Struct fields

  The following is static metadata, captured once when the ROM is loaded:

    * `:rom` — the resolved ROM path
    * `:legal_actions` — every action the console accepts, as `Alex.Action` atoms
    * `:minimal_actions` — the subset that does anything in this game
    * `:modes` — available game modes (integers)
    * `:difficulties` — available difficulty switches (integers)
    * `:screen_dims` — `{height, width}` of the screen
    * `:ram_size` — number of RAM bytes (always 128)

  ALEx also maintains some bookkeeping information:

    * `:episode_reward` — summed reward since the last `reset/1`

  All other game state (lives, frame number, the screen, RAM) is read live from the
  emulator on demand rather than cached, so it can never go stale.
  """

  alias Alex.{Action, Native}

  @enforce_keys [:ref, :rom]
  defstruct [
    :ref,
    :rom,
    :legal_actions,
    :minimal_actions,
    :modes,
    :difficulties,
    :screen_dims,
    :ram_size,
    episode_reward: 0
  ]

  @type t :: %__MODULE__{
          ref: reference(),
          rom: String.t(),
          legal_actions: [Action.t()],
          minimal_actions: [Action.t()],
          modes: [non_neg_integer()],
          difficulties: [non_neg_integer()],
          screen_dims: {pos_integer(), pos_integer()},
          ram_size: non_neg_integer(),
          episode_reward: number()
        }

  @doc false
  # Builds an env from a freshly-loaded interface ref by reading its static
  # metadata. Assumes the ROM has already been loaded on `ref`.
  @spec from_ref(reference(), String.t()) :: t()
  def from_ref(ref, rom) do
    {height, width} = Native.screen_dims(ref)

    %__MODULE__{
      ref: ref,
      rom: rom,
      legal_actions: Enum.map(Native.legal_action_set(ref), &Action.from_integer/1),
      minimal_actions: Enum.map(Native.minimal_action_set(ref), &Action.from_integer/1),
      modes: Native.available_modes(ref),
      difficulties: Native.available_difficulties(ref),
      screen_dims: {height, width},
      ram_size: byte_size(Native.get_ram(ref))
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(env, opts) do
      {h, w} = env.screen_dims

      concat([
        "#Alex.Env<",
        to_doc(
          [
            rom: Path.basename(env.rom),
            screen: "#{h}x#{w}",
            minimal_actions: length(env.minimal_actions),
            episode_reward: env.episode_reward
          ],
          opts
        ),
        ">"
      ])
    end
  end
end
