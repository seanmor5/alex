# Supported ROMs

ALEx supports every game the underlying Arcade Learning Environment supports.
Rather than maintaining a static list here, query what ALE provides — the set is
determined by the ALE release ALEx is built against (currently `v0.12.0`).

ALEx does not bundle ROMs (other than `tetris`, used as a test fixture). See the
[Configuration Guide](configuration.html) for how to provide them; the easiest
route is `pip install ale-py`, whose bundled ROMs ALEx auto-detects.

## Listing available ROMs

```elixir
Alex.ROM.list()
#=> ["tetris", ...]   # whatever is in your configured ROM directory
```

ROM names are the snake-cased game titles without extension, e.g. `"breakout"`,
`"space_invaders"`, `"ms_pacman"`. Pass a name (or an explicit path) to
`Alex.new/2`:

```elixir
env = Alex.new("space_invaders")
```

For the canonical list of games and their details, see the
[ALE documentation](https://ale.farama.org/).
