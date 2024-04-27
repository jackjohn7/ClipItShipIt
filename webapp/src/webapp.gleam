import env
import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import lustre/element/html.{html}
import mist.{type Connection, type ResponseData}
import web_utils

pub fn main() {
  let assert env.Vars(port) = env.get_environment()

  io.println("Hello from webapp!")
  let empty_body =
    mist.Bytes(bytes_builder.from_string("Page not found, brother :("))
  let not_found = response.set_body(response.new(404), empty_body)

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        [] -> index(req)
        ["clip", id] -> clip(id, req)
        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}

fn index(_: Request(Connection)) -> Response(ResponseData) {
  let res = response.new(200)
  let html =
    html([], [
      web_utils.make_head("ClipIt&ShipIt", "Capture the moment"),
      html.body([], [html.h1([], [html.text("Clips")])]),
    ])

  response.set_body(res, web_utils.render(html))
}

fn clip(id: String, _: Request(Connection)) -> Response(ResponseData) {
  let res = response.new(200)
  let html =
    html([], [
      web_utils.make_head(id, "placeholder description"),
      html.body([], [html.h1([], [html.text("You're watching " <> id <> "!")])]),
    ])

  response.set_body(res, web_utils.render(html))
}
