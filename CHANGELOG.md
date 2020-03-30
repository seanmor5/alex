# v0.1.0

# v0.2.0
* Changed location of libale_c target to `priv`.
* Changes to `mix.exs` due to compilation issues.

# v0.3.0
* Fixed double compilation bug.
* Stopped shipping libale_c with package which caused compilation to fail.
* Added Safety Checks to `get_` and `set_` NIFs so they no longer SegFault when given bad arguments.