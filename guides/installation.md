# Installation

ALEx builds the Arcade Learning Environment from source at compile time, so it
needs a build toolchain. The ALE source is fetched automatically — it is not
vendored into ALEx.

## Dependencies

You need:

  * a C++17 compiler (clang or gcc)
  * [CMake](https://cmake.org/) 3.14+
  * zlib development headers
  * git (to fetch the pinned ALE release)

SDL is **optional** and only required if you want an on-screen display or sound
(`display_screen: true` / `sound: true`).

### macOS

```shell
brew install cmake
# optional, for display/sound:
brew install sdl2
```

### Linux

```shell
sudo apt-get install build-essential cmake zlib1g-dev git
# optional, for display/sound:
sudo apt-get install libsdl2-dev
```

### Windows

ALEx has not been tested on Windows. Contributions welcome.

## Add to Mix

```elixir
defp deps do
  [
    {:alex, "~> 0.4"},
    # optional, only for the Livebook integration:
    {:kino, "~> 0.12"}
  ]
end
```

## Compile

```shell
mix deps.get
mix compile
```

The first compile clones and builds the pinned ALE release (a minute or two) and
then compiles the native binding. The built library is cached under `_build`, so
later compiles are fast. To force a rebuild of the native side, run
`mix compile --force`; to clear the cached ALE entirely, remove
`_build/<env>/ale`.

## Enabling SDL (display / sound)

The default build is headless. To build with SDL support, set the `ALE_SDL`
environment variable when compiling:

```shell
ALE_SDL=ON mix compile --force
```
