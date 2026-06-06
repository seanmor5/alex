# Configuration

## Emulator options

Pass options to `Alex.new/2`. Emulator settings are applied before the ROM is
loaded (as ALE requires); game configuration is applied afterwards.

| Option | Type | Description |
| --- | --- | --- |
| `:random_seed` | integer | Seed for reproducibility |
| `:repeat_action_probability` | float | Sticky-action probability (ALE default `0.25`) |
| `:frame_skip` | integer | Number of frames each action is held |
| `:max_num_frames_per_episode` | integer | Episode truncation limit |
| `:display_screen` | boolean | Open an SDL window (SDL build only) |
| `:sound` | boolean | Enable audio (SDL build only) |
| `:mode` | integer | Initial game mode (must be in `env.modes`) |
| `:difficulty` | integer | Initial difficulty (must be in `env.difficulties`) |
| `:rom_dir` | string | Directory to resolve the ROM name against |

```elixir
env = Alex.new("breakout", random_seed: 123, repeat_action_probability: 0.0)
```

Modes and difficulties can also be changed after loading; both reset the episode
so the change takes effect:

```elixir
env = Alex.set_mode(env, 1)
env = Alex.set_difficulty(env, 0)
```

## ROM directory

ALEx resolves a game name to a `.bin` file using the first of these that is set:

1. a `:rom_dir` option passed to the call,
2. the `:alex, :rom_dir` application environment,
3. the `ALE_ROM_DIR` operating-system environment variable,
4. the `roms/` directory of an installed `ale-py` (auto-detected), or
5. the `priv/roms` directory bundled with ALEx (contains only `tetris`).

```elixir
# config/config.exs
config :alex, rom_dir: "/path/to/roms"
```

The simplest way to obtain a complete, correctly-named ROM set is
`pip install ale-py`, which ALEx will then auto-detect. See `Alex.ROM` for the
resolution functions, and `Alex.ROM.list/1` to list what is available in
your configured directory.

To install ROMs into your ROM directory, use the `mix alex.roms` task:

```shell
# import from an installed ale-py
mix alex.roms --ale-py

# or download and extract an archive you point it at
mix alex.roms --url https://example.com/roms.tar.gz

# or copy from a local directory
mix alex.roms --from /path/to/roms
```

See `mix help alex.roms` for all options.

## SDL build

The native build is headless by default. Rebuild with SDL to use
`:display_screen` / `:sound`:

```shell
ALE_SDL=ON mix compile --force
```
