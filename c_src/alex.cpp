// ALEx native interface.
//
// A thin Fine-based binding over the Arcade Learning Environment C++ API. Each
// function maps almost 1:1 onto an `ale::ALEInterface` method. Errors (bad ROM,
// unavailable mode, etc.) surface as C++ exceptions which Fine converts into
// Elixir exceptions, so there is no manual {:ok, _} / {:error, _} wrapping here
// -- that policy lives in the Elixir layer.
//
// Observations (screen, RAM, serialized state) are returned as binaries rather
// than lists, which is dramatically cheaper than the original list-based NIF.

#include <fine.hpp>

#include <ale/ale_interface.hpp>
#include <ale/common/Constants.h>
#include <ale/common/Log.hpp>

#include <cstring>
#include <string>
#include <vector>

namespace alex {

using ale::ALEInterface;
using ale::ALEState;

// Resources surfaced to Elixir as opaque reference terms.
FINE_RESOURCE(ALEInterface);
FINE_RESOURCE(ALEState);

namespace atoms {
auto ok = fine::Atom("ok");
}

// --- Lifecycle ---------------------------------------------------------------

fine::ResourcePtr<ALEInterface> new_interface(ErlNifEnv *) {
  // ALE prints a welcome banner and per-ROM info at Info level straight from the
  // interface/console constructors. Quiet it down to keep stdout clean; genuine
  // errors are still reported.
  ale::Logger::setMode(ale::Logger::Error);
  return fine::make_resource<ALEInterface>();
}

// --- Settings ----------------------------------------------------------------

fine::Atom set_string(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                      std::string_view key, std::string_view value) {
  ale->setString(std::string(key), std::string(value));
  return atoms::ok;
}

fine::Atom set_int(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                   std::string_view key, int64_t value) {
  ale->setInt(std::string(key), static_cast<int>(value));
  return atoms::ok;
}

fine::Atom set_bool(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                    std::string_view key, bool value) {
  ale->setBool(std::string(key), value);
  return atoms::ok;
}

fine::Atom set_float(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                     std::string_view key, double value) {
  ale->setFloat(std::string(key), static_cast<float>(value));
  return atoms::ok;
}

std::string get_string(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                       std::string_view key) {
  return ale->getString(std::string(key));
}

int64_t get_int(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                std::string_view key) {
  return ale->getInt(std::string(key));
}

bool get_bool(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
              std::string_view key) {
  return ale->getBool(std::string(key));
}

double get_float(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                 std::string_view key) {
  return ale->getFloat(std::string(key));
}

// --- ROM / game loop ---------------------------------------------------------

fine::Atom load_rom(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                    std::string_view path) {
  ale->loadROM(std::string(path));
  return atoms::ok;
}

int64_t act(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale, int64_t action) {
  return ale->act(static_cast<ale::Action>(action));
}

bool game_over(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->game_over();
}

bool game_truncated(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->game_truncated();
}

fine::Atom reset_game(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  ale->reset_game();
  return atoms::ok;
}

int64_t lives(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->lives();
}

int64_t get_frame_number(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->getFrameNumber();
}

int64_t get_episode_frame_number(ErlNifEnv *,
                                 fine::ResourcePtr<ALEInterface> ale) {
  return ale->getEpisodeFrameNumber();
}

// --- Action sets / modes / difficulties --------------------------------------

template <typename Vec> std::vector<int64_t> to_int_vector(const Vec &in) {
  std::vector<int64_t> out;
  out.reserve(in.size());
  for (const auto &v : in) {
    out.push_back(static_cast<int64_t>(v));
  }
  return out;
}

std::vector<int64_t> legal_action_set(ErlNifEnv *,
                                      fine::ResourcePtr<ALEInterface> ale) {
  return to_int_vector(ale->getLegalActionSet());
}

std::vector<int64_t> minimal_action_set(ErlNifEnv *,
                                        fine::ResourcePtr<ALEInterface> ale) {
  return to_int_vector(ale->getMinimalActionSet());
}

std::vector<int64_t> available_modes(ErlNifEnv *,
                                     fine::ResourcePtr<ALEInterface> ale) {
  return to_int_vector(ale->getAvailableModes());
}

fine::Atom set_mode(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                    int64_t mode) {
  ale->setMode(static_cast<ale::game_mode_t>(mode));
  return atoms::ok;
}

int64_t get_mode(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->getMode();
}

std::vector<int64_t>
available_difficulties(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return to_int_vector(ale->getAvailableDifficulties());
}

fine::Atom set_difficulty(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                          int64_t difficulty) {
  ale->setDifficulty(static_cast<ale::difficulty_t>(difficulty));
  return atoms::ok;
}

int64_t get_difficulty(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  return ale->getDifficulty();
}

// --- Observations ------------------------------------------------------------

// Screen dimensions as a {height, width} tuple, matching the row-major layout
// of the RGB/grayscale binaries below.
std::tuple<int64_t, int64_t>
screen_dims(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale) {
  const auto &screen = ale->getScreen();
  return {static_cast<int64_t>(screen.height()),
          static_cast<int64_t>(screen.width())};
}

// Interleaved RGB, row-major: size == height * width * 3.
fine::Term screen_rgb(ErlNifEnv *env, fine::ResourcePtr<ALEInterface> ale) {
  std::vector<unsigned char> buffer;
  ale->getScreenRGB(buffer);
  return fine::make_new_binary(env, reinterpret_cast<char *>(buffer.data()),
                               buffer.size());
}

// One byte per pixel, row-major: size == height * width.
fine::Term screen_grayscale(ErlNifEnv *env,
                            fine::ResourcePtr<ALEInterface> ale) {
  std::vector<unsigned char> buffer;
  ale->getScreenGrayscale(buffer);
  return fine::make_new_binary(env, reinterpret_cast<char *>(buffer.data()),
                               buffer.size());
}

// The 128 bytes of console RAM.
fine::Term get_ram(ErlNifEnv *env, fine::ResourcePtr<ALEInterface> ale) {
  const auto &ram = ale->getRAM();
  return fine::make_new_binary(
      env, reinterpret_cast<const char *>(ram.array()), ram.size());
}

fine::Atom save_screen_png(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                           std::string_view path) {
  ale->saveScreenPNG(std::string(path));
  return atoms::ok;
}

// --- State snapshots ---------------------------------------------------------

fine::ResourcePtr<ALEState> clone_state(ErlNifEnv *,
                                        fine::ResourcePtr<ALEInterface> ale,
                                        bool include_rng) {
  return fine::make_resource<ALEState>(ale->cloneState(include_rng));
}

fine::Atom restore_state(ErlNifEnv *, fine::ResourcePtr<ALEInterface> ale,
                         fine::ResourcePtr<ALEState> state) {
  ale->restoreState(*state);
  return atoms::ok;
}

fine::Term serialize_state(ErlNifEnv *env, fine::ResourcePtr<ALEState> state) {
  std::string serialized = state->serialize();
  return fine::make_new_binary(env, serialized.data(), serialized.size());
}

fine::ResourcePtr<ALEState> deserialize_state(ErlNifEnv *,
                                              std::string_view serialized) {
  return fine::make_resource<ALEState>(std::string(serialized));
}

// --- Registration ------------------------------------------------------------
//
// FINE_NIF token-pastes the function name, so it must be invoked with the
// unqualified name inside the enclosing namespace.

FINE_NIF(new_interface, 0);
FINE_NIF(set_string, 0);
FINE_NIF(set_int, 0);
FINE_NIF(set_bool, 0);
FINE_NIF(set_float, 0);
FINE_NIF(get_string, 0);
FINE_NIF(get_int, 0);
FINE_NIF(get_bool, 0);
FINE_NIF(get_float, 0);
FINE_NIF(load_rom, 0);
FINE_NIF(act, 0);
FINE_NIF(game_over, 0);
FINE_NIF(game_truncated, 0);
FINE_NIF(reset_game, 0);
FINE_NIF(lives, 0);
FINE_NIF(get_frame_number, 0);
FINE_NIF(get_episode_frame_number, 0);
FINE_NIF(legal_action_set, 0);
FINE_NIF(minimal_action_set, 0);
FINE_NIF(available_modes, 0);
FINE_NIF(set_mode, 0);
FINE_NIF(get_mode, 0);
FINE_NIF(available_difficulties, 0);
FINE_NIF(set_difficulty, 0);
FINE_NIF(get_difficulty, 0);
FINE_NIF(screen_dims, 0);
FINE_NIF(screen_rgb, 0);
FINE_NIF(screen_grayscale, 0);
FINE_NIF(get_ram, 0);
FINE_NIF(save_screen_png, 0);
FINE_NIF(clone_state, 0);
FINE_NIF(restore_state, 0);
FINE_NIF(serialize_state, 0);
FINE_NIF(deserialize_state, 0);

} // namespace alex

FINE_INIT("Elixir.Alex.Native");
