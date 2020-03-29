# Installation

## Install Dependencies

The ALE requires [CMake](https://cmake.org/) and [SDL](https://www.libsdl.org/). You need to install them before compiling ALEx.

### Linux

```
$ sudo apt-get install libsdl1.2-dev libsdl-gfx1.2-dev libsdl-image1.2-dev cmake
```

### Mac

```
$ brew install cmake
$ brew install sdl
```

### Windows

ALEx hasn't been tested on Windows yet. Sorry :(

## Add to Mix

Add `alex` to your dependencies:

```
defp deps do
    {:alex, "~> 0.2.0"}
end
```

## Compile

Run `mix deps.get, deps.compile`.

The first compilation will take quite a bit of time as the ALE compiles. After that you should be good to go!