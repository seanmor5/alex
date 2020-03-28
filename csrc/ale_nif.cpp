#include "nifpp.h"
#include <ale_interface.hpp>

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

static int load(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info)
{
  nifpp::register_resource<ale::ALEInterface>(env, nullptr, "ALEInterface");
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
  {"get_available_modes", 1, get_available_modes},
  {"get_available_modes_size", 1, get_available_modes_size},
  {"set_mode", 2, set_mode},
  {"get_available_difficulties", 1, get_available_difficulties},
  {"get_available_difficulties_size", 1, get_available_difficulties_size},
  {"set_difficulty", 2, set_difficulty},
  {"get_legal_action_set", 1, get_legal_action_set},
  {"get_legal_action_set_size", 1, get_legal_action_set_size},
  {"get_minimal_action_set", 1, get_minimal_action_set},
  {"get_minimal_action_set_size", 1, get_minimal_action_set_size},
  {"get_frame_number", 1, get_frame_number},
  {"lives", 1, lives},
  {"get_episode_frame_number", 1, get_episode_frame_number},
  {"get_ram_size", 1, get_ram_size},
  {"get_screen_height", 1, get_screen_height},
  {"get_screen_width", 1, get_screen_width},
  {"reset_game", 1, reset_game}
};

ERL_NIF_INIT(Elixir.Alex.Interface, nif_funcs, load, nullptr, nullptr, nullptr);