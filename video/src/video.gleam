import gleam/erlang/process
import gleam/otp/actor

type State {
  State(files: List(String))
}

// IDEA: perhaps this should be set up in reverse where the
//  caller can listen for messages giving status updates on
//  the video processing's progress. I think this idea might
//  be a bit more straight-forward. I need to research how
//  other apps tend to handle this though.

pub type Message {
  Compress
  // size is in seconds
  Chunk(size: Int)
  // in px
  Scale(x: Int, y: Int)
  Transcribe
  Complete
}

fn handle_process(message: Message, state) {
  case message {
    Compress -> {
      // compress video file
      //  replace file in state with compressed
      actor.continue(state)
    }
    Chunk(_) -> {
      // break video into chunks
      //  replace files in state with chunks
      actor.continue(state)
    }
    Scale(_, _) -> {
      // resize video resolution
      //  create scaled files in state
      actor.continue(state)
    }
    Transcribe -> {
      // transcribe video for captions
      //  store transcription data somewhere
      actor.continue(state)
    }
    Complete -> {
      // verify that all completed properly
      //  and exit accordingly
      actor.Stop(process.Normal)
    }
  }
}

pub fn create_upload_processor(_caller, _file) {
  actor.start(State, handle_process)
}

pub fn compress_video(caller) {
  process.send(caller, Compress)
  caller
}

pub fn chunk_video(caller, x) {
  process.send(caller, Chunk(x))
  caller
}

pub fn scale_video(caller, x, y) {
  process.send(caller, Scale(x, y))
  caller
}

pub fn transcribe(caller) {
  process.send(caller, Transcribe)
  caller
}

pub fn complete(caller) {
  process.send(caller, Complete)
  caller
}

pub fn main() {
  // resulting API is like this... (just putting dummy values for caller and file)
  let assert Ok(processor) = create_upload_processor(1, 2)
  processor
  |> compress_video
  |> transcribe
  |> scale_video(1280, 720)
  |> chunk_video(5)
  |> complete
}
