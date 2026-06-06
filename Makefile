# Makefile for ALEx
#
# Responsibilities:
#   1. Fetch the upstream Arcade Learning Environment at a pinned tag.
#   2. Build + install its C++ library (static libale.a + headers) with CMake,
#      using system libraries (zlib) -- no vcpkg required.
#   3. Compile the Fine-based NIF (c_src/alex.cpp) and link it against libale,
#      producing priv/alex.so.
#
# The ALE source/build lives under the Mix build directory so it is cleaned with
# the rest of the build artifacts and never committed to the repo.

# --- Inputs (provided by mix.exs make_env, with sane fallbacks) --------------
ALE_VERSION       ?= v0.12.0
MIX_BUILD_DIR     ?= _build/dev
FINE_INCLUDE_DIR  ?= $(shell elixir -e "IO.puts Fine.include_dir()" 2>/dev/null)
ERTS_INCLUDE_DIR  ?= $(shell erl -noshell -eval 'io:format("~s/erts-~s/include", [code:root_dir(), erlang:system_info(version)])' -s init stop)

# Enable SDL for on-screen display / sound (requires SDL2 dev libs). Off by
# default since headless RL never needs it.
ALE_SDL           ?= OFF

# Upstream repository
ALE_REPO          ?= https://github.com/Farama-Foundation/Arcade-Learning-Environment.git

# --- Derived paths -----------------------------------------------------------
ALE_ROOT     = $(MIX_BUILD_DIR)/ale
ALE_SRC      = $(ALE_ROOT)/src-$(ALE_VERSION)
ALE_BUILD    = $(ALE_ROOT)/build-$(ALE_VERSION)
ALE_INSTALL  = $(ALE_ROOT)/install-$(ALE_VERSION)
ALE_LIB      = $(ALE_INSTALL)/lib/libale.a
ALE_INCLUDE  = $(ALE_INSTALL)/include

PRIV_DIR     = priv
NIF          = $(PRIV_DIR)/alex.so
WASM_DIR     = $(PRIV_DIR)/wasm

# --- Toolchain ---------------------------------------------------------------
CXX      ?= c++
CXXFLAGS += -std=c++17 -O3 -fPIC -fvisibility=hidden -Wall
CPPFLAGS += -I$(FINE_INCLUDE_DIR) -I$(ERTS_INCLUDE_DIR) -I$(ALE_INCLUDE)
LDLIBS   += $(ALE_LIB) -lz

# Platform-specific shared-object flags.
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
else
	LDFLAGS += -shared
	LDLIBS  += -lpthread
endif

# WebAssembly assets for Alex.Kino, pulled from the matching npm release.
ALE_WASM_VERSION = $(patsubst v%,%,$(ALE_VERSION))
ALE_WASM_BASE    = https://unpkg.com/@farama/ale-wasm@$(ALE_WASM_VERSION)

.PHONY: all clean clean-ale wasm

all: $(NIF)

# --- 1. Fetch ALE ------------------------------------------------------------
$(ALE_SRC)/CMakeLists.txt:
	@echo "==> Fetching ALE $(ALE_VERSION)"
	rm -rf $(ALE_SRC)
	git clone --depth 1 --branch $(ALE_VERSION) $(ALE_REPO) $(ALE_SRC)

# --- 2. Build + install ALE --------------------------------------------------
$(ALE_LIB): $(ALE_SRC)/CMakeLists.txt
	@echo "==> Building ALE (this can take a few minutes the first time)"
	cmake -S $(ALE_SRC) -B $(ALE_BUILD) \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_CPP_LIB=ON \
		-DBUILD_PYTHON_LIB=OFF \
		-DBUILD_VECTOR_LIB=OFF \
		-DSDL_SUPPORT=$(ALE_SDL) \
		-DCMAKE_INSTALL_PREFIX=$(ALE_INSTALL)
	cmake --build $(ALE_BUILD) --target install --config Release -j

# --- 3. Compile the NIF ------------------------------------------------------
$(NIF): c_src/alex.cpp $(ALE_LIB)
	@mkdir -p $(PRIV_DIR)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) c_src/alex.cpp $(LDFLAGS) $(LDLIBS) -o $(NIF)

# --- WebAssembly assets (fetched on demand by Alex.Kino) ---------------------
# Run `make wasm` (or let Alex.Kino fetch on first use). Kept out of `all` so the
# core build never requires network access for the browser bundle.
wasm: $(WASM_DIR)/ale.js $(WASM_DIR)/ale.wasm $(WASM_DIR)/ale.data

$(WASM_DIR)/%:
	@mkdir -p $(WASM_DIR)
	@echo "==> Fetching $* from @farama/ale-wasm@$(ALE_WASM_VERSION)"
	curl -fsSL $(ALE_WASM_BASE)/$* -o $@

# --- Cleanup -----------------------------------------------------------------
clean:
	rm -f $(NIF)

clean-ale:
	rm -rf $(ALE_ROOT)
