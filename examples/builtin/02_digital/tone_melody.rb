# toneMelody
#
# Plays "Shave and a Haircut" on a piezo speaker on pin 8.
#
# https://docs.arduino.cc/built-in-examples/digital/toneMelody/

# Notes inlined from pitches.h: NOTE_C4, NOTE_G3, NOTE_G3, NOTE_A3, NOTE_G3, rest, NOTE_B3, NOTE_C4
melody = [262, 196, 196, 220, 196, 0, 247, 262]
durations = [4, 8, 8, 4, 4, 4, 4, 4]

i = 0
while i < 8
  note_duration = 1000 / durations[i]
  note = melody[i]
  if note > 0
    tone(8, note, note_duration)
  end
  pause = note_duration * 130 / 100
  delay_ms(pause)
  no_tone(8)
  i += 1
end

loop do
  # melody plays once at startup; nothing to do here
end
