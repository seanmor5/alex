# v0.4.0

A ground-up rewrite. **This release is not backwards compatible** with 0.3.x.

## Build
* The ALE is no longer vendored in the repository. It is fetched at a pinned
  release (`v0.12.0`) and built from source via a `Makefile` driven by
  `elixir_make`, using system zlib (no vcpkg required). SDL is optional
  (`ALE_SDL=ON`).
* NIFs are now written with [Fine](https://hexdocs.pm/fine) instead of the
  hand-rolled `nifpp` bindings.

## API
* New high-level API centered on `%Alex.Env{}`, an opaque, mutable emulator
  handle with static metadata captured at load. `Alex.new/2`, `Alex.step/2`
  (returns `{env, info}`), `Alex.reset/1`, and explicit `Alex.set_mode/2` /
  `Alex.set_difficulty/2`.
* Actions are first-class atoms via `Alex.Action`.
* Screen and RAM observations are returned as zero-copy binaries with shape
  (`Alex.Screen`, `Alex.RAM`), replacing the old list-based representation.
* `Alex.Snapshot` replaces `Alex.State`, with `serialize/1` / `deserialize/1`.
* `Alex.ROM` resolves ROMs by name against a configurable ROM directory; the
  bundled MD5 list and vendored ROMs were removed.
* New `mix alex.roms` task installs ROMs from `ale-py`, a URL, or a local
  directory.
* Low-level access moved to `Alex.Native` (formerly `Alex.Interface`).

## Livebook
* New optional `Alex.Kino` integration: `play/2` runs ALE's WebAssembly build in
  the browser for interactive play, and `view/2` / `push_frame/2` stream a native
  env's frames so you can watch an Elixir-driven agent. `%Alex.Env{}` also renders
  its current screen via `Kino.Render`.

# v0.3.0
* Fixed double compilation bug.
* Stopped shipping libale_c with package which caused compilation to fail.
* Added Safety Checks to `get_` and `set_` NIFs so they no longer SegFault when given bad arguments.

# v0.2.0
* Changed location of libale_c target to `priv`.
* Changes to `mix.exs` due to compilation issues.

# v0.1.0
