#include "nifpp.h"
#include <ale_interface.hpp>
#include <iostream>

const nifpp::str_atom ok("ok");
const nifpp::str_atom error("error");

static ERL_NIF_TERM ale_new(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  auto ptr = nifpp::construct_resource<ale::ALEInterface>();

  nifpp::TERM interface = nifpp::make(env, ptr);

  return nifpp::make(env, std::make_tuple(ok, interface));
}

static ERL_NIF_TERM get_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);

  std::string value = interface->getString(key);

  nifpp::TERM ret = nifpp::make(env, value);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_int(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);

  int value = interface->getInt(key);

  nifpp::TERM ret = nifpp::make(env, value);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_bool(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);

  bool value = interface->getBool(key);

  nifpp::TERM ret = nifpp::make(env, value);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_float(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);

  float value = interface->getFloat(key);

  nifpp::TERM ret = nifpp::make(env, value);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM set_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key, value;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);
  nifpp::get(env, argv[2], value);

  interface->setString(key, value);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM set_int(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;
  int value;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);
  nifpp::get(env, argv[2], value);

  interface->setInt(key, value);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM set_bool(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;
  bool value;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);
  nifpp::get(env, argv[2], value);

  interface->setBool(key, value);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM set_float(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string key;
  double value;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], key);
  nifpp::get(env, argv[2], value);

  interface->setFloat(key, (float) value);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM load_rom(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string path;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], path);

  interface->loadROM(path);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM act(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int action;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], action);

  int reward = interface->act((ale::Action) action);

  nifpp::TERM ret = nifpp::make(env, reward);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM game_over(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  bool over;

  nifpp::get(env, argv[0], interface);

  over = interface->game_over();

  nifpp::TERM status = nifpp::make(env, over);

  return nifpp::make(env, std::make_tuple(ok, status));
}

static ERL_NIF_TERM reset_game(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  interface->reset_game();

  nifpp::TERM ale_ref = nifpp::make(env, interface);

  return nifpp::make(env, std::make_tuple(ok, ale_ref));
}

static ERL_NIF_TERM get_available_modes(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ModeVect modes_vect;

  nifpp::get(env, argv[0], interface);

  modes_vect = interface->getAvailableModes();

  nifpp::TERM ret = nifpp::make(env, modes_vect);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_available_modes_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int size;

  nifpp::get(env, argv[0], interface);

  size = interface->getAvailableModes().size();

  nifpp::TERM ret = nifpp::make(env, size);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM set_mode(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int mode;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], mode);

  interface->setMode(mode);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM get_available_difficulties(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::DifficultyVect diff_vect;

  nifpp::get(env, argv[0], interface);

  diff_vect = interface->getAvailableDifficulties();

  nifpp::TERM ret = nifpp::make(env, diff_vect);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_available_difficulties_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int size;

  nifpp::get(env, argv[0], interface);

  size = interface->getAvailableDifficulties().size();

  nifpp::TERM ret = nifpp::make(env, size);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_difficulty(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int difficulty;

  nifpp::get(env, argv[0], interface);

  difficulty = interface->environment->getDifficulty();

  return nifpp::make(env, std::make_tuple(ok, difficulty));
}

static ERL_NIF_TERM set_difficulty(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int difficulty;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], difficulty);

  interface->setDifficulty(difficulty);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM get_legal_action_set(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ActionVect actions_vect;

  nifpp::get(env, argv[0], interface);

  actions_vect = interface->getLegalActionSet();

  nifpp::TERM ret = nifpp::make(env, actions_vect);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_legal_action_set_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int size;

  nifpp::get(env, argv[0], interface);

  size = interface->getLegalActionSet().size();

  nifpp::TERM ret = nifpp::make(env, size);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_minimal_action_set(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ActionVect actions_vect;

  nifpp::get(env, argv[0], interface);

  actions_vect = interface->getMinimalActionSet();

  nifpp::TERM ret = nifpp::make(env, actions_vect);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_minimal_action_set_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int size;

  nifpp::get(env, argv[0], interface);

  size = interface->getMinimalActionSet().size();

  nifpp::TERM ret = nifpp::make(env, size);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_frame_number(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int frame;

  nifpp::get(env, argv[0], interface);

  frame = interface->getFrameNumber();

  nifpp::TERM ret = nifpp::make(env, frame);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM lives(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int lives;

  nifpp::get(env, argv[0], interface);

  lives = interface->lives();

  nifpp::TERM ret = nifpp::make(env, lives);

  return nifpp::make(env, std::make_tuple(ok, ret));
}

static ERL_NIF_TERM get_episode_frame_number(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  int frame;

  nifpp::get(env, argv[0], interface);

  frame = interface->getEpisodeFrameNumber();

  nifpp::TERM ret = nifpp::make(env, frame);

  return nifpp::make(env, std::make_tuple(ok, frame));
}

static ERL_NIF_TERM get_screen(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  size_t w, h;
  ale::pixel_t *screen_data;

  nifpp::get(env, argv[0], interface);

  screen_data = interface->getScreen().getArray();

  return nifpp::make(env, std::make_tuple(ok, screen_data));
}

static ERL_NIF_TERM get_ram(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  const unsigned char* ale_ram;
  unsigned char* ram;

  nifpp::get(env, argv[0], interface);

  ale_ram = interface->getRAM().array();

  return nifpp::make(env, std::make_tuple(ok, ale_ram));
}

static ERL_NIF_TERM get_ram_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  nifpp::TERM ram_size = nifpp::make(env, interface->getRAM().size());

  return nifpp::make(env, std::make_tuple(ok, ram_size));
}

static ERL_NIF_TERM get_screen_height(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  nifpp::TERM screen_height = nifpp::make(env, interface->getScreen().height());

  return nifpp::make(env, std::make_tuple(ok, screen_height));
}

static ERL_NIF_TERM get_screen_width(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  nifpp::TERM screen_width = nifpp::make(env, interface->getScreen().width());

  return nifpp::make(env, std::make_tuple(ok, screen_width));
}

static ERL_NIF_TERM get_screen_rgb(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  size_t w, h, screen_size;
  ale::pixel_t *ale_screen_data;
  std::vector<unsigned char> output_buffer;

  nifpp::get(env, argv[0], interface);

  w = interface->getScreen().width();
  h = interface->getScreen().height();
  screen_size = w*h;

  ale_screen_data = interface->getScreen().getArray();

  interface->theOSystem->colourPalette().applyPaletteRGB(output_buffer, ale_screen_data, screen_size);

  return nifpp::make(env, std::make_tuple(ok, output_buffer));
}

static ERL_NIF_TERM get_screen_grayscale(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  size_t w, h, screen_size;
  ale::pixel_t *ale_screen_data;
  std::vector<unsigned char> output_buffer;

  nifpp::get(env, argv[0], interface);

  w = interface->getScreen().width();
  h = interface->getScreen().height();
  screen_size = w*h;

  ale_screen_data = interface->getScreen().getArray();

  interface->theOSystem->colourPalette().applyPaletteGrayscale(output_buffer, ale_screen_data, screen_size);

  return nifpp::make(env, std::make_tuple(ok, output_buffer));
}

static ERL_NIF_TERM save_screen_png(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  std::string path;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], path);

  interface->saveScreenPNG(path);

  nifpp::TERM ok_status = nifpp::make(env, ok);

  return ok_status;
}

static ERL_NIF_TERM save_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  interface->saveState();

  return nifpp::make(env, ok);
}

static ERL_NIF_TERM load_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;

  nifpp::get(env, argv[0], interface);

  interface->loadState();

  return nifpp::make(env, ok);
}

static ERL_NIF_TERM clone_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ALEState state;

  nifpp::get(env, argv[0], interface);

  state = interface->cloneState();

  auto ptr = nifpp::construct_resource<ale::ALEState>(state);

  nifpp::TERM ret = nifpp::make(env, ptr);

  return nifpp::make(env, std::make_tuple(ok, ptr));
}

static ERL_NIF_TERM restore_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ALEState* state;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], state);

  interface->restoreState(*state);

  return nifpp::make(env, ok);
}

static ERL_NIF_TERM clone_system_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ALEState state;

  nifpp::get(env, argv[0], interface);

  state = interface->cloneSystemState();

  auto ptr = nifpp::construct_resource<ale::ALEState>(state);

  return nifpp::make(env, std::make_tuple(ok, ptr));
}

static ERL_NIF_TERM restore_system_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEInterface* interface;
  ale::ALEState* state;

  nifpp::get(env, argv[0], interface);
  nifpp::get(env, argv[1], state);

  interface->restoreSystemState(*state);

  return nifpp::make(env, ok);
}

static ERL_NIF_TERM encode_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEState* state;
  std::string serial;

  nifpp::get(env, argv[0], state);

  serial = state->serialize();

  return nifpp::make(env, std::make_tuple(ok, serial));
}

static ERL_NIF_TERM encode_state_len(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ale::ALEState* state;
  int len;

  nifpp::get(env, argv[0], state);

  len = state->serialize().length();

  return nifpp::make(env, std::make_tuple(ok, len));
}

static ERL_NIF_TERM decode_state(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  std::string serial;
  int len;
  ale::ALEState state;

  nifpp::get(env, argv[0], serial);
  nifpp::get(env, argv[1], len);

  std::string str(serial, len);

  auto ptr = nifpp::construct_resource<ale::ALEState>(str);

  return nifpp::make(env, std::make_tuple(ok, ptr));
}

static int load(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info)
{
  nifpp::register_resource<ale::ALEInterface>(env, nullptr, "ALEInterface");
  nifpp::register_resource<ale::ALEState>(env, nullptr, "ALEState");
  return 0;
}

static ErlNifFunc nif_funcs[] =
{
  {"ale_new", 0, ale_new},
  {"get_string", 2, get_string},
  {"get_int", 2, get_int},
  {"get_bool", 2, get_bool},
  {"get_float", 2, get_float},
  {"set_string", 3, set_string},
  {"set_int", 3, set_int},
  {"set_bool", 3, set_bool},
  {"set_float", 3, set_float},
  {"load_rom", 2, load_rom},
  {"act", 2, act},
  {"game_over", 1, game_over},
  {"reset_game", 1, reset_game},
  {"get_available_modes", 1, get_available_modes},
  {"get_available_modes_size", 1, get_available_modes_size},
  {"set_mode", 2, set_mode},
  {"get_available_difficulties", 1, get_available_difficulties},
  {"get_available_difficulties_size", 1, get_available_difficulties_size},
  {"get_difficulty", 1, get_difficulty},
  {"set_difficulty", 2, set_difficulty},
  {"get_legal_action_set", 1, get_legal_action_set},
  {"get_legal_action_set_size", 1, get_legal_action_set_size},
  {"get_minimal_action_set", 1, get_minimal_action_set},
  {"get_minimal_action_set_size", 1, get_minimal_action_set_size},
  {"get_frame_number", 1, get_frame_number},
  {"lives", 1, lives},
  {"get_episode_frame_number", 1, get_episode_frame_number},
  {"get_screen", 1, get_screen},
  {"get_ram", 1, get_ram},
  {"get_ram_size", 1, get_ram_size},
  {"get_screen_height", 1, get_screen_height},
  {"get_screen_width", 1, get_screen_width},
  {"get_screen_rgb", 1, get_screen_rgb},
  {"get_screen_grayscale", 1, get_screen_grayscale},
  {"save_state", 1, save_state},
  {"load_state", 1, load_state},
  {"clone_state", 1, clone_state},
  {"restore_state", 2, restore_state},
  {"clone_system_state", 1, clone_system_state},
  {"restore_system_state", 2, restore_system_state},
  {"save_screen_png", 2, save_screen_png},
  {"encode_state", 1, encode_state},
  {"encode_state_len", 1, encode_state_len},
  {"decode_state", 2, decode_state}
};

ERL_NIF_INIT(Elixir.Alex.Interface, nif_funcs, load, nullptr, nullptr, nullptr);