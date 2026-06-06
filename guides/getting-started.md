# Getting Started

ALEx is an Elixir interface to the Arcade Learning Environment (ALE).

## Install ALEx

See the [Installation Guide](installation.html).

## Creating an environment

Load a game by name (resolved against your ROM directory — see the
[Configuration Guide](configuration.html)) or by an explicit path to a `.bin`
file:

```elixir
env = Alex.new("breakout", random_seed: 123)
```

`Alex.new/2` returns an `%Alex.Env{}` that wraps a single, **mutable** emulator.
Its struct holds static metadata captured once at load — the available actions,
modes, difficulties, and screen dimensions:

```elixir
Alex.minimal_actions(env)
#=> [:noop, :fire, :right, :left]
env.screen_dims
#=> {210, 160}
```

## Playing an episode

`Alex.step/2` applies an action and returns the updated env together with an
`info` map. Actions are `Alex.Action` atoms (or their integer values):

```elixir
env =
  Enum.reduce_while(Stream.cycle([:play]), env, fn _, env ->
    {env, info} = Alex.step(env, Enum.random(Alex.minimal_actions(env)))
    if info.game_over?, do: {:halt, env}, else: {:cont, env}
  end)

IO.puts("Score: #{Alex.episode_reward(env)}")
```

The `info` map contains `:reward`, `:episode_reward`, `:game_over?`,
`:truncated?`, `:lives`, `:frame`, and `:episode_frame`.

## Observations

Screen and RAM observations are returned as binaries with their shape, so you
can hand them straight to a tensor library:

```elixir
{rgb, {height, width, 3}, :u8} = Alex.Screen.rgb(env)
{gray, {height, width}, :u8}   = Alex.Screen.grayscale(env)
ram                            = Alex.RAM.read(env)  # 128-byte binary
```

For example, with `Nx`:

```elixir
{rgb, shape, :u8} = Alex.Screen.rgb(env)
tensor = rgb |> Nx.from_binary(:u8) |> Nx.reshape(shape)
```

## Resetting and snapshots

Start a new episode with `Alex.reset/1`. To branch or rewind *within* an episode,
take a snapshot and restore it later:

```elixir
snap = Alex.Snapshot.save(env)
{env, _} = Alex.step(env, :fire)
env = Alex.Snapshot.restore(env, snap)  # back to where the snapshot was taken
```

Snapshots can be serialized to a binary for storage and rebuilt with
`Alex.Snapshot.deserialize/1`.

## Screenshots

```elixir
Alex.Screen.save_png(env, "frame.png")
```

## Livebook

If you have `:kino` installed, you can play a game interactively or watch an
agent — see `Alex.Kino`.

## More information

The [Arcade Learning
Environment](https://github.com/Farama-Foundation/Arcade-Learning-Environment)
documentation covers the underlying platform in depth.
