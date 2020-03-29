# ALEx

> (A)rcade (L)earning (E)nvironment for Eli(x)ir.

## Overview

ALEx is an implementation of the [Arcade Learning Environment](https://github.com/mgbellemare/Arcade-Learning-Environment) for Elixir.

ALEx exposes the ALE C Wrapper as NIFs
## Installation

First, install ALE dependencies:

### Linux

```shell
$ sudo apt-get install libsdl1.2-dev libsdl-gfx1.2-dev libsdl-image1.2-dev cmake
```

### Mac

```shell
$ brew install sdl
$ brew install cmake
```

Then, add `alex` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:alex, "~> 0.1.0"}
  ]
end
```

Finally, run `mix deps.get, deps.compile`. The first compilation will take quite a bit of time.
