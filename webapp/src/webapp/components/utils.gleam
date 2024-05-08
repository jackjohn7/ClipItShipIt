import gleam/bytes_builder
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import mist

pub fn make_head(title: String, desc: String) {
  html.head([], [
    html.title([], title),
    html.meta([attribute.attribute("description", desc)]),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href("/static/css/app.css"),
    ]),
  ])
}

pub fn render(ele: element.Element(t)) {
  ele
  |> element.to_document_string
  |> bytes_builder.from_string
  |> mist.Bytes
}
