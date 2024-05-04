import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import peggy

// IDEA: perhaps this should be set up in reverse where the
//  caller can listen for messages giving status updates on
//  the video processing's progress. I think this idea might
//  be a bit more straight-forward. I need to research how
//  other apps tend to handle this though.

pub type VideoUpdate {
  Compressing
  Chunking
  Saving
  Done
}

pub fn start_process(caller: Subject(VideoUpdate), id, file_path) {
  // compress video
  peggy.new_command()
  |> peggy.input(file_path)
  |> peggy.video_codec("h264")
  |> peggy.audio_codec("mp2")
  |> peggy.output(id <> "_compressed.mp4")
  |> peggy.exec_sync
}
