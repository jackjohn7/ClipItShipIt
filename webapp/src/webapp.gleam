import env
import gleam/dict
import gleam/erlang/process
import mist
import webapp/router
import wisp

pub fn main() {
  let assert env.Vars(port) = env.get_environment()

  let _video_subjects = dict.new()
  let secret_key_base = wisp.random_string(64)

  wisp.configure_logger()
  let assert Ok(_) =
    wisp.mist_handler(router.create_router(router.new_state), secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}
