# Alex

**[https://github.com/mgbellemare/Arcade-Learning-Environment](Arcade Learning Environment) for Elixir**

## Overview

## Installation

First, install ALE dependencies:

```shell
$ sudo apt-get install libsdl1.2-dev libsdl-gfx1.2-dev libsdl-image1.2-dev cmake
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
