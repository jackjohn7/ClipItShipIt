import env/internal
import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import lustre/element
import lustre/element/html.{html}
import mist.{type Connection, type ResponseData}

pub fn main() {
  let env = get_environment()

  io.println("Hello from webapp!")
  let empty_body = mist.Bytes(bytes_builder.from_string("404 bro"))
  let not_found = response.set_body(response.new(404), empty_body)

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["greet", name] -> greet(name)
        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

fn greet(name: String) -> Response(ResponseData) {
  let res = response.new(200)
  let html =
    html([], [
      html.head([], [html.title([], "Greetings!")]),
      html.body([], [html.h1([], [html.text("Hey there, " <> name <> "!")])]),
    ])

  response.set_body(
    res,
    html
      |> element.to_document_string
      |> bytes_builder.from_string
      |> mist.Bytes,
  )
}
