log.level.set(5)
audio.samplerate.set(48000)
settings.decoder.priorities.ffmpeg.set(-1)

fname = argv(default="",1)
out = "#{fname}+test_mono.wav"

if file.exists(out) then
  file.remove(out)
end

s = single(fname)

s = once(s)

clock.assign_new(sync='none',[s])

def on_done () =
  j = process.read("ffprobe -v quiet -print_format json -show_streams #{process.quote(out)}")

  let json.parse ( parsed: {
    streams: [{
      channels: int,
      sample_rate: string
    }]
  }) = j

  let [stream] = parsed.streams

  if stream.channels == 1 and stream.sample_rate == "48000" then
    test.pass()
  else
    test.fail()
  end
end

output.file(fallible=true, on_stop=on_done, %wav(mono), out, s)
