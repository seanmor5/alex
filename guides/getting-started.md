# Getting Started

ALEx is implemented the Arcade Learning Environment for Elixir.

## Install ALEx

See the [Installation Guide](installation.html).

## Creating a Random Agent

Interaction with ALEx is easy. First, create a new interface and set your confgiuration options:

```
# Create ALEx interface
interface = Alex.new()

# Set options
interface =
    interface
    |> Alex.set_option(:display_screen, true)
    |> Alex.set_option(:random_seed, 123)
```

You can also pass options as a `Keyword` to `Alex.new/1`:

```
interface = Alex.new(display_screen: true, random_seed: 123)
```

Next, load a ROM:

```
# Load Tetris
tetris = Alex.load(interface, "priv/tetris.bin")
```

Finally, play an episode:

```
episode =
    fn game, episode ->
        # If the game is over, return the score
        if Alex.game_over?(game) do
            game.reward
        else
            # Take a random action
            game = Alex.step(game, Enum.random(game.legal_actions))
            episode.(game, episode)
        end
    end

# Run an episode
tetris = episode.(tetris, episode)
```

## Starting Over

You can easily restart an episode with `Alex.reset/1`:

```
tetris = episode.(tetris, episode)

# Run it back from the start
tetris = Alex.reset(tetris)
tetris = episode.(tetris, episode)
```

## Taking a Screenshot

ALEx allows you to take a screenshot of the current screen at any time using `Alex.screenshot/2`:

```
# Run an episode
tetris = episode(tetris, episode)

# See how it ended
Alex.screenshot(tetris)
```

You can provide a path. The default path is the current directory with the current UTC time.

## Supported ROMs

ALEx supports all ROMS supported by the ALE. ROMs can be easily found on repositories online. ALEx will verify the checksum of a ROM automatically before loading it.

[Supported ROMs](supported-roms.html) has a list of all supported ROMs and their MD5 checksums.

## More Information

You'll want to checkout the [Arcade Learning Environment](https://github.com/mgbellemare/Arcade-Learning-Environment) to learn more.