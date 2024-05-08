import glanoid
import gleam/erlang/process
import gleam/http.{Get, Post}
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import video
import webapp/components/utils
import wisp.{type Request, type Response, type UploadedFile}

pub type AppState {
  AppState(priv_dir: String)
}

pub fn new_state() {
  let assert Ok(priv_directory) = wisp.priv_directory("webapp")
  AppState(priv_directory <> "/static")
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  handle_request(req)
}

pub fn create_router(app_state: AppState) {
  let assert Ok(nanoid) = glanoid.make_generator(glanoid.default_alphabet)
  fn(req: Request) -> Response {
    use req <- middleware(req)
    use <- wisp.serve_static(req, under: "/static", from: app_state.priv_dir)

    case wisp.path_segments(req) {
      [] -> index(req)
      ["upload"] -> upload(req, nanoid)
      _ -> wisp.not_found()
    }
  }
}

fn index(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  let content =
    html([], [
      utils.make_head("ClipIt&ShipIt", "Capture the moment"),
      html.body([], [
        html.h1([attribute.class("text-3xl")], [html.text("Clips")]),
        html.a([attribute.href("/upload")], [html.text("Upload here!")]),
      ]),
    ])
    |> element.to_string_builder

  wisp.ok()
  |> wisp.html_body(content)
}

fn upload(req: Request, nanoid) -> Response {
  case req.method {
    Get -> {
      let content =
        html([], [
          utils.make_head("ClipIt&ShipIt", "Capture the moment"),
          html.body([], [
            html.h1([], [html.text("Upload")]),
            html.p([], [html.text("Upload a video!")]),
            html.form(
              [
                attribute.method("POST"),
                attribute.action("/upload"),
                attribute.enctype("multipart/form-data"),
              ],
              [
                html.input([
                  attribute.type_("file"),
                  attribute.id("video_file"),
                  attribute.name("video_file"),
                  attribute.accept(["video/mp4"]),
                ]),
                html.button([attribute.type_("submit")], [html.text("Submit")]),
              ],
            ),
          ]),
        ])
        |> element.to_string_builder

      wisp.ok()
      |> wisp.html_body(content)
    }
    Post -> {
      use formdata <- wisp.require_form(req)
      let file = list.key_find(formdata.files, "video_file")

      case file {
        Ok(wisp.UploadedFile(_name, path)) -> {
          // generate an ID for the video
          let id = nanoid(18)
          let ret = process.new_subject()

          video.start_process(ret, id, path)

          wisp.ok()
        }
        Error(_) -> {
          wisp.response(400)
        }
      }
    }
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}
